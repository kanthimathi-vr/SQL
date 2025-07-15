import json
import sys

def load_resume(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def print_resume(resume):
    print("\n========== RESUME ==========\n")

    # Basic Info
    basics = resume.get("basics", {})
    print(f"Name       : {basics.get('name', 'N/A')}")
    print(f"Email      : {basics.get('email', 'N/A')}")
    print(f"Phone      : {basics.get('phone', 'N/A')}")
    print(f"Location   : {basics.get('location', {}).get('city', '')}, {basics.get('location', {}).get('country', '')}")
    print()

    # Summary
    if "summary" in basics:
        print("Summary:\n" + basics["summary"] + "\n")

    # Work Experience
    if "work" in resume:
        print("Work Experience:")
        for job in resume["work"]:
            print(f"- {job.get('position', '')} at {job.get('company', '')} ({job.get('startDate', '')} – {job.get('endDate', 'Present')})")
            if job.get("summary"):
                print(f"  Summary: {job['summary']}")
            print()

    # Education
    if "education" in resume:
        print("Education:")
        for edu in resume["education"]:
            print(f"- {edu.get('studyType', '')} in {edu.get('area', '')}, {edu.get('institution', '')} ({edu.get('startDate', '')} – {edu.get('endDate', '')})")
        print()

    # Skills
    if "skills" in resume:
        print("Skills:")
        for skill in resume["skills"]:
            print(f"- {skill.get('name', '')}: {', '.join(skill.get('keywords', []))}")
        print()

    # Projects
    if "projects" in resume:
        print("Projects:")
        for proj in resume["projects"]:
            print(f"- {proj.get('name', '')}: {proj.get('description', '')}")
        print()

    print("============================\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python json_resume_viewer.py <resume.json>")
        sys.exit(1)

    file_path = sys.argv[1]
    try:
        resume = load_resume(file_path)
        print_resume(resume)
    except FileNotFoundError:
        print("File not found.")
    except json.JSONDecodeError:
        print("Invalid JSON format.")

if __name__ == "__main__":
    main()
