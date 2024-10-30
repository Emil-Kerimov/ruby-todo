require 'rspec'
require_relative 'Todo'

RSpec.describe Todo do
  let(:todo) { Todo.new("Test", "2024-11-11") }

  it 'initializes correct' do
    expect(todo.title).to eq("Test")
    expect(todo.deadline).to eq(Date.parse("2024-11-11"))
    expect(todo.completed).to be false
  end

  it 'marks a task as completed' do
    todo.mark_completed
    expect(todo.completed).to be true
  end

  it 'updates task attributes' do
    todo.update(title: "Updated", deadline: "2024-12-12")
    expect(todo.title).to eq("Updated")
    expect(todo.deadline).to eq(Date.parse("2024-12-12"))
  end

  it 'converts task to a hash for saving' do
    expect(todo.to_hash).to eq({
                                 'title' => "Test",
                                 'deadline' => "2024-11-11",
                                 'completed' => false
                               })
  end
end

RSpec.describe TaskManager do
  let(:manager) { TaskManager.new }

  before(:each) do
    allow(File).to receive(:exist?).and_return(false)
    allow(File).to receive(:write)
  end

  it 'adds a new task' do
    manager.add_task("New", "2024-11-11")
    expect(manager.instance_variable_get(:@tasks).size).to eq(1)
    expect(manager.instance_variable_get(:@tasks).first.title).to eq("New")
  end

  it 'removes a task by title' do
    manager.add_task("Task to Delete", "2024-11-11")
    manager.remove_task("Task to Delete")
    expect(manager.instance_variable_get(:@tasks).size).to eq(0)
  end

  it 'edits a task by title' do
    manager.add_task("Edit", "2024-11-11")
    manager.edit_task("Edit", new_title: "Edited", new_deadline: "2024-11-11")
    task = manager.instance_variable_get(:@tasks).first
    expect(task.title).to eq("Edited")
    expect(task.deadline).to eq(Date.parse("2024-11-11"))
  end

  it 'marks a task as completed' do
    manager.add_task("Complete", "2024-11-11")
    manager.mark_task_as_completed("Complete")
    task = manager.instance_variable_get(:@tasks).first
    expect(task.completed).to be true
  end

  it 'filters tasks by status' do
    manager.add_task("Completed", "2024-11-01")
    manager.add_task("Incomplete", "2024-11-02")
    manager.mark_task_as_completed("Completed")
    completed_tasks = manager.filter_tasks(status: true)
    expect(completed_tasks.map(&:title)).to eq(["Completed"])
  end

  it 'filters tasks by deadline' do
    manager.add_task("Early Task", "2024-11-01")
    manager.add_task("Late Task", "2024-12-10")
    filtered_tasks = manager.filter_tasks(before: "2024-11-02")
    expect(filtered_tasks.map(&:title)).to eq(["Early Task"])
  end
end