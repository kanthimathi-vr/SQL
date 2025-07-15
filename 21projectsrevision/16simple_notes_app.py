import sqlite3
from datetime import datetime

DB_NAME = "notes.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def create_note(title, content):
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cur.execute("INSERT INTO notes (title, content, timestamp) VALUES (?, ?, ?)", 
                (title, content, timestamp))
    conn.commit()
    conn.close()
    print("✅ Note created.")

def list_notes():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("SELECT id, title, timestamp FROM notes ORDER BY timestamp DESC")
    notes = cur.fetchall()
    conn.close()
    if notes:
        print("\n📝 All Notes:")
        for note in notes:
            print(f"[{note[0]}] {note[1]} — {note[2]}")
    else:
        print("📭 No notes found.")

def view_note(note_id):
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("SELECT title, content, timestamp FROM notes WHERE id = ?", (note_id,))
    note = cur.fetchone()
    conn.close()
    if note:
        print(f"\n📄 {note[0]} ({note[2]})\n{note[1]}")
    else:
        print("❌ Note not found.")

def update_note(note_id, new_title, new_content):
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("UPDATE notes SET title = ?, content = ? WHERE id = ?", 
                (new_title, new_content, note_id))
    if cur.rowcount == 0:
        print("❌ Note not found.")
    else:
        print("✏️ Note updated.")
    conn.commit()
    conn.close()

def delete_note(note_id):
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("DELETE FROM notes WHERE id = ?", (note_id,))
    if cur.rowcount == 0:
        print("❌ Note not found.")
    else:
        print("🗑️ Note deleted.")
    conn.commit()
    conn.close()

def main_menu():
    init_db()
    while True:
        print("\n--- Simple Notes App ---")
        print("1. Create Note")
        print("2. List Notes")
        print("3. View Note")
        print("4. Update Note")
        print("5. Delete Note")
        print("6. Exit")

        choice = input("Choose an option [1-6]: ")

        if choice == "1":
            title = input("Title: ")
            content = input("Content:\n")
            create_note(title, content)
        elif choice == "2":
            list_notes()
        elif choice == "3":
            note_id = input("Enter Note ID to view: ")
            view_note(note_id)
        elif choice == "4":
            note_id = input("Enter Note ID to update: ")
            new_title = input("New Title: ")
            new_content = input("New Content:\n")
            update_note(note_id, new_title, new_content)
        elif choice == "5":
            note_id = input("Enter Note ID to delete: ")
            delete_note(note_id)
        elif choice == "6":
            print("👋 Goodbye!")
            break
        else:
            print("❗ Invalid option. Please choose between 1 and 6.")

if __name__ == "__main__":
    main_menu()
