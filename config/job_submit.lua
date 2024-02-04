--
-- Slurm job submit lua script.
--
-- Capabilities:
--
-- - Estimate  watt usagway of submitted jobs according to the requested
--   resources.
-- - Add `watts` licenses to submitted jobs according to watt estimation.
--

_resource_power_consumption_map = {
    cards = 340,
    gpu = 190,
    cpu = 5
}

--
-- In several cases of job submission in Slurm, the `cpus-per-task` field is
-- set to `NO_VAL16`, which is `-1` as a 16-bit *signed* integer.
--
-- In the Slurm context of the lua job-submit plugin, the `cpus_per_task` field
-- is represented as a 16-bit *unsigned* integer, thus the value is not `-1`,
-- but `65534`.
--
-- In these cases, the job-submit plugin tries to add watt licenses for 65534
-- cpus, which adds up to 327670 watt licenses.
_invalid_cpus = 65534

--
-- Parse generic resource string to map.
--
function _parse_gres(gres_string)
    gres_map = {}
    for resource in gres_string:gmatch("[^,]+") do
        resource = (resource:sub(0, #"gres:") == "gres:") and resource:sub(#"gres:" + 1) or resource
        resource_name, quantity = resource:match("(%w+):(%d+)")
        gres_map[resource_name] = quantity
    end
    return gres_map
end

-- ============================================================================
--
-- Slurm job_submit/lua interface:
--
-- ============================================================================

--
--  Slurm job submission function.
--
--  This function is called when the slurm controller recieves a new job
--  submission request, and is executed inside the in-memory lua interpreter
--  in `slurmctld` with the full context and state of the slurm controller at
--  submission time.
--
function slurm_job_submit(job_desc, part_list, submit_uid)
    power_consumption = 0

    if job_desc.gres ~= nil then
        gres_map = _parse_gres(job_desc.gres)
        for resource_name, quantity in pairs(gres_map) do
            power_consumption = power_consumption + _resource_power_consumption_map[resource_name] * quantity
        end
    end
    if job_desc.cpus_per_task ~= nil and job_desc.cpus_per_task ~= _invalid_cpus then
        slurm.log_info("cpus_per_task = %s", job_desc.cpus_per_task)
        power_consumption = power_consumption + _resource_power_consumption_map.cpu * job_desc.cpus_per_task
    end
    if job_desc.tres_per_task ~= nil then
        slurm.log_info("tres_per_task = %s", job_desc.tres_per_task)
    end

    slurm.log_info("job takes %d watts", power_consumption)

    licenses = ""
    if job_desc.licenses ~= nil then
        licenses = job_desc.licenses .. ","
    end
    watts_desc = "watts:%d"
    licenses = licenses .. watts_desc:format(power_consumption)
    job_desc.licenses = licenses

    return slurm.SUCCESS
end

function slurm_job_modify(job_desc, part_list, submit_uid)
    slurm.log_info("job modified")
end
