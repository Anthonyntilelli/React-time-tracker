# frozen_string_literal: true

# rubocop:disable Rails/Output
DATES_LIST = (0...42).map do |i|
  (Time.zone.now.prev_occurring(:friday).midnight - i.day)
end.reverse

Employee.destroy_all
ClockEvent.destroy_all
AdminEvent.destroy_all

puts 'Hiring employees'
employees = [
  Employee.hire('John Smith', 'password123!', 5, 40, is_admin: true),
  Employee.hire('John Doe', 'password123!', 10, 80, is_admin: true),
  Employee.hire('Jane Smith', 'password123!', 12, 40),
  Employee.hire('John Doe', 'password123!', 10, 80)
]

puts 'Adding clock events'
DATES_LIST.each do |start|
  puts "-> Adding Day #{start}"
  # Skip weekends
  next if start.saturday? || start.sunday?

  employees.each do |emp|
    puts "---> Employee: #{emp.id} #{emp.name}"
    emp.clock_in(time: start + 12.hours + rand(5..50).seconds)
    emp.meal_start(time: start + 16.hours + rand(5..50).seconds)
    emp.meal_end(time: start + 17.hours + rand(5..50).seconds)
    emp.break_start(time: start + 19.hours + rand(5..50).seconds)
    emp.break_end(time: start + 19.hours + 30.minutes + rand(5..50).seconds)
    emp.clock_out(time: start + 21.hours + rand(5..50).seconds)
  end
end

puts 'Add Sick Employee'
sick_employee = Employee.hire('Sick Joe', 'password123!', 3, 40)
sick_employee.modify_pto(Employee.first, 'Testing', current: 40)

puts 'Adding clock with Sick events'
DATES_LIST.each do |start|
  puts "-> Adding Day with Sick #{start}"
  # Skip weekends
  next if start.saturday? || start.sunday?

  sick_employee.clock_in(time: start + 12.hours + rand(5..50).seconds)
  sick_employee.meal_start(time: start + 16.hours + rand(5..50).seconds)
  puts "--> Attempting to add Sick => Left: #{sick_employee.pto_current})"
  next if sick_employee.sick(5, time: start + 17.hours + rand(5..50).seconds)

  # Must work if does not have PTO
  puts 'No Pto left denied'
  sick_employee.meal_end(time: start + 16.hours + rand(5..50).seconds)
  sick_employee.break_start(time: start + 19.hours + rand(5..50).seconds)
  sick_employee.break_end(time: start + 19.hours + 30.minutes + rand(5..50).seconds)
  sick_employee.clock_out(time: start + 21.hours + rand(5..50).seconds)
end

puts 'Add Vacation Employee'
vacation_employee = Employee.hire('Lacks Joe', 'password123!', 3, 40)
vacation_employee.modify_pto(Employee.first, 'Testing', current: 40)

puts 'Adding clock with Vacation events'
DATES_LIST.each do |start|
  puts "-> Adding Day with Sick #{start}"
  # Skip weekends
  next if start.saturday? || start.sunday?

  vacation_employee.clock_in(time: start + 12.hours + rand(5..50).seconds)
  vacation_employee.meal_start(time: start + 16.hours + rand(5..50).seconds)
  puts "--> Attempting to add Vacation => Left: #{vacation_employee.pto_current})"
  next if vacation_employee.use_pto(5, time: start + 17.hours + rand(5..50).seconds)

  puts 'No Pto left denied'
  vacation_employee.meal_end(time: start + 16.hours + rand(5..50).seconds)
  vacation_employee.break_start(time: start + 19.hours + rand(5..50).seconds)
  vacation_employee.break_end(time: start + 19.hours + 30.minutes + rand(5..50).seconds)
  vacation_employee.clock_out(time: start + 21.hours + rand(5..50).seconds)
end

puts "Terminate: vacation employee PayOut: #{vacation_employee.end_employment(
  Employee.first, 'Test: Kept requesting vacation'
)}"
# rubocop:enable Rails/Output
