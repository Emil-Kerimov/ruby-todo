require 'json'
require 'date'

class Todo
  attr_accessor :title, :deadline, :completed

  def initialize(title, deadline, completed: false)
    @title = title
    @deadline = Date.parse(deadline)
    @completed = completed
  end

  def mark_completed
    @completed = true
  end

  def update(title: nil, deadline: nil)
    @title = title if title
    @deadline = Date.parse(deadline) if deadline
  end

  def to_hash
    {
      'title' => @title,
      'deadline' => @deadline.to_s,
      'completed' => @completed
    }
  end

  def self.from_hash(task_hash)
    new(task_hash['title'], task_hash['deadline'], completed: task_hash['completed'])
  end
end

class TaskManager
  FILE_NAME = 'todo.json'

  def initialize
    @tasks = load_tasks
  end

  def add_task(title, deadline)
    @tasks << Todo.new(title, deadline)
    save_tasks
  end

  def remove_task(title)
    @tasks.reject! { |task| task.title == title }
    save_tasks
  end

  def edit_task(title, new_title: nil, new_deadline: nil)
    task = @tasks.find { |t| t.title == title }
    return unless task

    task.update(title: new_title, deadline: new_deadline)
    save_tasks
  end

  def mark_task_as_completed(title)
    task = @tasks.find { |t| t.title == title }
    return unless task

    task.mark_completed
    save_tasks
  end

  def filter_tasks(status: nil, before: nil)
    filtered = @tasks.dup
    filtered.select! { |task| task.completed == status } unless status.nil?
    filtered.select! { |task| task.deadline < Date.parse(before) } if before
    filtered
  end

  def display_tasks(tasks = @tasks)
    tasks.each do |task|
      status = task.completed ? 'done' : 'in progress'
      puts "#{status} #{task.title} - until: #{task.deadline}"
    end
  end

  private

  def load_tasks
    return [] unless File.exist?(FILE_NAME)

    JSON.parse(File.read(FILE_NAME)).map { |task_data| Todo.from_hash(task_data) }
  end

  def save_tasks
    File.write(FILE_NAME, JSON.pretty_generate(@tasks.map(&:to_hash)))
  end
end

def main(commands = [])
  manager = TaskManager.new

  commands.each do |input|
    command, *args = input.split

    case command
    when 'add'
      title = args[0]
      deadline = args[1]
      manager.add_task(title, deadline)
    when 'remove'
      title = args.join(' ')
      manager.remove_task(title)
    when 'edit'
      title = args[0]
      new_title = args[1]
      new_deadline = args[2]
      manager.edit_task(title, new_title: new_title, new_deadline: new_deadline)
    when 'filter'
      filter_type = args[0].to_i

      if filter_type == 1
        status = args[1].downcase == 'y'
        tasks = manager.filter_tasks(status: status)
      elsif filter_type == 2
        before_date = args[1]
        tasks = manager.filter_tasks(before: before_date)
      else
        puts 'Invalid filter type.'
        next
      end

      manager.display_tasks(tasks)
    when 'list'
      manager.display_tasks
    when 'complete'
      title = args.join(' ')
      manager.mark_task_as_completed(title)
      puts "#{title} marked as completed."
    when 'exit'
      break
    else
      puts 'Try again'
    end
  end
end

if __FILE__ == $0
  puts 'Commands: add, remove, edit, filter, list, complete, exit'
  puts 'menu'
  puts 'add title deadline(YYYY-MM-DD)'
  puts 'remove title'
  puts 'edit title new_title new_deadline'
  puts 'filter type (1 for status, 2 for date) date'
  puts 'list'
  puts 'complete title'
  puts 'exit'

  commands = []

  loop do
    print "\nEnter command: "
    input = gets.chomp
    commands << input
    break if input.downcase == 'exit'
  end

  main(commands)
end