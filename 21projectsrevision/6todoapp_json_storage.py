import json
import os

TODO_FILE = "todo_list.json"

def load_todos():
    if os.path.exists(TODO_FILE):
        with open(TODO_FILE, "r", encoding="utf-8") as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                print("Warning: Corrupted todo file. Starting fresh.")
    return []

def save_todos(todos):
    with open(TODO_FILE, "w", encoding="utf-8") as f:
        json.dump(todos, f, indent=4)

def show_todos(todos):
    if not todos:
        print("\nNo tasks found.\n")
        return

    print("\nYour Tasks:")
    for idx, task in enumerate(todos, 1):
        status = "✔️" if task["completed"] else "❌"
        print(f"{idx}. [{status}] {task['title']}")
    print()

def add_task(todos):
    title = input("Enter task title: ").strip()
    if title:
        todos.append({"title": title, "completed": False})
        print(f"Added task: {title}")
    else:
        print("Task title cannot be empty.")
    return todos

def toggle_task(todos):
    show_todos(todos)
    try:
        idx = int(input("Enter task number to toggle complete/incomplete: ")) - 1
        if 0 <= idx < len(todos):
            todos[idx]["completed"] = not todos[idx]["completed"]
            status = "completed" if todos[idx]["completed"] else "incomplete"
            print(f"Marked task '{todos[idx]['title']}' as {status}.")
        else:
            print("Invalid task number.")
    except ValueError:
        print("Please enter a valid number.")
    return todos

def delete_task(todos):
    show_todos(todos)
    try:
        idx = int(input("Enter task number to delete: ")) - 1
        if 0 <= idx < len(todos):
            removed = todos.pop(idx)
            print(f"Deleted task: {removed['title']}")
        else:
            print("Invalid task number.")
    except ValueError:
        print("Please enter a valid number.")
    return todos

def main():
    todos = load_todos()

    while True:
        print("\n--- Todo App ---")
        print("1. View Tasks")
        print("2. Add Task")
        print("3. Toggle Task Status")
        print("4. Delete Task")
        print("5. Save & Exit")
        choice = input("Choose an option [1-5]: ").strip()

        if choice == "1":
            show_todos(todos)
        elif choice == "2":
            todos = add_task(todos)
        elif choice == "3":
            todos = toggle_task(todos)
        elif choice == "4":
            todos = delete_task(todos)
        elif choice == "5":
            save_todos(todos)
            print("Tasks saved. Goodbye!")
            break
        else:
            print("Invalid option.")

if __name__ == "__main__":
    main()
