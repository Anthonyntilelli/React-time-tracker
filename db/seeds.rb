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
  Employee.hire('Jane Smith', 'password123!', 10, 80, is_admin: true),
  Employee.hire('John DoE', 'password123!', 12, 40),
  Employee.hire('Jane Doe', 'password123!', 10, 80)
]

puts 'Adding clock events'
DATES_LIST.each do |start|
  puts "-> Adding Day #{start}"
  # Skip weekends
  next if start.saturday? || start.sunday?

  employees.each do |emp|
    puts "---> Employee: #{emp.id} #{emp.name}"
    raise 'Next and clockEvent 0 do not match' unless emp.next_clock_event_category == ClockEvent::CATEGORY_ORDER[0]

    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[0], time: start + 12.hours + rand(5..50).seconds)
    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[1], time: start + 16.hours + rand(5..50).seconds)
    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[2], time: start + 17.hours + rand(5..50).seconds)
    raise 'Next and clockEvent 3 do not match' unless emp.next_clock_event_category == ClockEvent::CATEGORY_ORDER[3]

    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[3], time: start + 19.hours + rand(5..50).seconds)
    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[4], time: start + 19.hours + 30.minutes + rand(5..50).seconds)
    emp.create_clock_event(ClockEvent::CATEGORY_ORDER[5], time: start + 21.hours + rand(5..50).seconds)
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
  unless sick_employee.next_clock_event_category == ClockEvent::CATEGORY_ORDER[0]
    raise 'Next and clockEvent 0 do not match'
  end

  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[0], time: start + 12.hours + rand(5..50).seconds)
  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[1], time: start + 16.hours + rand(5..50).seconds)
  puts "--> Attempting to add Sick => Left: #{sick_employee.pto_current})"
  next if sick_employee.sick(5, time: start + 17.hours + rand(5..50).seconds)

  # Must work if does not have PTO
  puts 'No Pto left denied'
  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[2], time: start + 17.hours + rand(5..50).seconds)
  unless sick_employee.next_clock_event_category == ClockEvent::CATEGORY_ORDER[3]
    raise 'Next and clockEvent 3 do not match'
  end

  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[3], time: start + 19.hours + rand(5..50).seconds)
  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[4],
                                   time: start + 19.hours + 30.minutes + rand(5..50).seconds)
  sick_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[5], time: start + 21.hours + rand(5..50).seconds)
end

puts 'Add Vacation Employee'
vacation_employee = Employee.hire('Vacation Joe', 'password123!', 3, 40)
vacation_employee.modify_pto(Employee.first, 'Testing', current: 40)

puts 'Adding clock with Vacation events'
DATES_LIST.each do |start|
  puts "-> Adding Day with Sick #{start}"
  # Skip weekends
  next if start.saturday? || start.sunday?

  unless vacation_employee.next_clock_event_category == ClockEvent::CATEGORY_ORDER[0]
    raise 'Next and clockEvent 0 do not match'
  end

  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[0], time: start + 12.hours + rand(5..50).seconds)
  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[1], time: start + 16.hours + rand(5..50).seconds)

  puts "--> Attempting to add Vacation => Left: #{vacation_employee.pto_current})"
  next if vacation_employee.use_pto(5, time: start + 17.hours + rand(5..50).seconds)

  puts 'No Pto left denied'
  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[2], time: start + 17.hours + rand(5..50).seconds)
  unless vacation_employee.next_clock_event_category == ClockEvent::CATEGORY_ORDER[3]
    raise 'Next and clockEvent 3 do not match'
  end

  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[3], time: start + 19.hours + rand(5..50).seconds)
  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[4],
                                       time: start + 19.hours + 30.minutes + rand(5..50).seconds)
  vacation_employee.create_clock_event(ClockEvent::CATEGORY_ORDER[5], time: start + 21.hours + rand(5..50).seconds)
end

puts "Terminate: vacation employee PayOut: #{vacation_employee.end_employment(
  Employee.first, 'Test: Kept requesting vacation'
)}"
# rubocop:enable Rails/Output
