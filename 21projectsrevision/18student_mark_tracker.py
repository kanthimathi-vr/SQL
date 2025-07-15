import sqlite3

DB_NAME = "students.db"
SUBJECTS = ["Math", "Science", "English"]

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    # Create students table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    """)
    # Create marks table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS marks (
            student_id INTEGER,
            subject TEXT,
            mark INTEGER,
            FOREIGN KEY(student_id) REFERENCES students(id)
        )
    """)
    conn.commit()
    conn.close()

def add_student():
    name = input("Student Name: ").strip()
    if not name:
        print("❗ Name cannot be empty.")
        return

    marks = {}
    for subj in SUBJECTS:
        while True:
            try:
                mark = int(input(f"Mark in {subj} (0-100): "))
                if 0 <= mark <= 100:
                    marks[subj] = mark
                    break
                else:
                    print("❗ Enter a valid mark between 0 and 100.")
            except ValueError:
                print("❗ Please enter a number.")

    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("INSERT INTO students (name) VALUES (?)", (name,))
    student_id = cur.lastrowid

    for subj, mark in marks.items():
        cur.execute("INSERT INTO marks (student_id, subject, mark) VALUES (?, ?, ?)",
                    (student_id, subj, mark))

    conn.commit()
    conn.close()
    print(f"✅ Added {name} with marks.")

def view_students():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM students ORDER BY name")
    students = cur.fetchall()

    if not students:
        print("📭 No students found.")
        conn.close()
        return

    for student_id, name in students:
        cur.execute("SELECT subject, mark FROM marks WHERE student_id = ?", (student_id,))
        marks = cur.fetchall()
        marks_dict = {subj: mark for subj, mark in marks}
        average = sum(marks_dict.values()) / len(marks_dict) if marks_dict else 0
        print(f"\n👤 {name}")
        for subj in SUBJECTS:
            print(f"  {subj}: {marks_dict.get(subj, 'N/A')}")
        print(f"  ➤ Average: {average:.2f}")

    conn.close()

def main_menu():
    init_db()
    while True:
        print("\n--- Student Mark Tracker ---")
        print("1. Add Student")
        print("2. View Students")
        print("3. Exit")

        choice = input("Choose an option [1-3]: ").strip()
        if choice == "1":
            add_student()
        elif choice == "2":
            view_students()
        elif choice == "3":
            print("👋 Bye!")
            break
        else:
            print("❗ Invalid choice. Pick 1, 2 or 3.")

if __name__ == "__main__":
    main_menu()
