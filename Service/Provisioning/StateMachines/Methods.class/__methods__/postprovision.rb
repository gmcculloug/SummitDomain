# $evm.log("info", "Listing Root Object Attributes:")
# $evm.root.attributes.sort.each { |k, v| $evm.log("info", "\t#{k}: #{v}") }
# $evm.log("info", "===========================================")
CLOUD = "AND (cloud IS TRUE)"
INFRA = "AND (cloud IS FALSE OR cloud IS NULL)"

task = $evm.root["service_template_provision_task"]
service = task.destination

key = service.options[:dialog].keys.detect {|k| k.to_s.include?("number_of_vms")}
vm_count = service.options.dig(:dialog, key).presence || 1

vm_type = INFRA

sql = <<~SQL
SELECT id FROM vms
WHERE power_state = 'on'
#{vm_type}
SQL

added_count = 0
$evm.vmdb(:vm).find_by_sql(sql).each do |vm|
  vm = $evm.vmdb(:vm).find(vm.id)
  if vm.service.nil?
    vm.add_to_service(service)
    added_count += 1
  end

  break if added_count == vm_count
end
