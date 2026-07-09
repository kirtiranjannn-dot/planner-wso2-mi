# Planner WSO2 MI

A RESTful Planner Backend built using **WSO2 Micro Integrator**, **Data Services**, and **PostgreSQL**.

## Tech Stack

- WSO2 Micro Integrator 4.4.0 / 4.6.0
- WSO2 VS Code Extension
- PostgreSQL
- Java 17
- Maven

---

## Project Structure

```
PlannerUAT
│
├── src/
├── deployment/
├── pom.xml
├── mvnw
├── mvnw.cmd
└── .gitignore
```

---

## Prerequisites

Before running the project, install:

- Java 17
- PostgreSQL
- WSO2 Micro Integrator 4.4.0 or later
- Visual Studio Code
- WSO2 MI Extension for VS Code

---

## Database Setup

1. Create a PostgreSQL database.

Example:

```sql
CREATE DATABASE planner_db_uat;
```

2. Execute the SQL script to create all tables.

```
database/schema.sql
```

3. Configure the datasource in WSO2 MI.

Datasource Name:

```
Postgres_DS
```

Update the following details according to your local PostgreSQL configuration:

- Host
- Port
- Database
- Username
- Password

---

## Running the Project

1. Open the project in VS Code.

2. Start the Embedded WSO2 MI Server.

3. Wait until the server starts successfully.

Base URL

```
http://localhost:8290/planneruat
```

---

# Users Module

Implemented APIs

| Method | Endpoint | Description |
|----------|-----------------------------|--------------------------------|
| POST | /users | Create User |
| GET | /users | Get All Users |
| GET | /users/count | Get Total Users |
| GET | /users/{id} | Get User by ID |
| GET | /users/uuid/{uuid} | Get User by UUID |
| GET | /users/username/{username} | Get User by Username |
| GET | /users/email/{email} | Get User by Email |
| PUT | /users/{id} | Update User |
| DELETE | /users/{id} | Soft Delete User |
| PUT | /users/{id}/activate | Activate User |
| PUT | /users/{id}/deactivate | Deactivate User |

---

## Response Format

All APIs return JSON responses.

Example

```json
{
    "User": {
        "UserDetails": [
            {
                "id": 1,
                "username": "Vikas",
                "email": "vikas@email.com"
            }
        ]
    }
}
```

---

## Git Workflow

Clone the repository

```bash
git clone https://github.com/kirtiranjannn-dot/planner-wso2-mi.git
```

Create a feature branch

```bash
git checkout -b feature/<module-name>
```

Example

```bash
git checkout -b feature/plans
```

Commit

```bash
git add .
git commit -m "Added Plans APIs"
```

Push

```bash
git push origin feature/plans
```

Create a Pull Request and merge into **main**.

---

## Contributors

- Kirti Ranjan
- Contributors are welcome through Pull Requests.

---

## Future Modules

- Plans
- Buckets
- Tasks
- Labels
- Comments
- Attachments
- Checklist Items
- Plan Members
- Task Activity

---

## License

This project is intended for learning and development purposes.
