CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE EXTENSION IF NOT EXISTS pgcrypto;


CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid VARCHAR(50) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    display_name VARCHAR(200),
    profile_image VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','INACTIVE','LOCKED')),
    last_login TIMESTAMP,
    tenant_id VARCHAR(100),
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

SELECT * FROM users;

CREATE TABLE plans (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid CHAR(36) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    owner_id BIGINT NOT NULL,
    color VARCHAR(30),
    icon VARCHAR(100),
    visibility VARCHAR(20) DEFAULT 'PRIVATE'
        CHECK (visibility IN ('PRIVATE','PUBLIC','TEAM')),
    status VARCHAR(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','ARCHIVED')),
    start_date DATE,
    end_date DATE,
    tenant_id VARCHAR(100),
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_plans_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id)
);

SELECT * FROM plans;


CREATE TABLE labels (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plan_id BIGINT,
    name VARCHAR(100),
    color VARCHAR(20)
);

SELECT * FROM labels;


CREATE TABLE buckets (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid CHAR(36) UNIQUE,
    plan_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    display_order INTEGER DEFAULT 0,
    color VARCHAR(20),
    status VARCHAR(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'ARCHIVED')),
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_buckets_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(id)
);

SELECT * FROM buckets;

CREATE TABLE tasks (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid CHAR(36) UNIQUE,
    bucket_id BIGINT NOT NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'MEDIUM'
        CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    status VARCHAR(20) DEFAULT 'TODO'
        CHECK (status IN ('TODO','IN_PROGRESS','BLOCKED','DONE','CANCELLED')),
    due_date DATE,
    start_date DATE,
    completed_date TIMESTAMP,
    estimated_hours NUMERIC(8,2),
    actual_hours NUMERIC(8,2),
    progress INTEGER DEFAULT 0,
    assigned_to BIGINT,
    parent_task_id BIGINT,
    display_order INTEGER DEFAULT 0,
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_tasks_bucket
        FOREIGN KEY (bucket_id)
        REFERENCES buckets(id),

    CONSTRAINT fk_tasks_parent
        FOREIGN KEY (parent_task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_tasks_assigned_to
        FOREIGN KEY (assigned_to)
        REFERENCES users(id)
);

SELECT * FROM tasks;

CREATE TABLE attachments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid CHAR(36) UNIQUE,
    task_id BIGINT NOT NULL,
    file_name VARCHAR(255),
    original_file_name VARCHAR(255),
    file_type VARCHAR(100),
    file_size BIGINT,
    storage_type VARCHAR(20) DEFAULT 'LOCAL'
        CHECK (storage_type IN ('LOCAL','S3','AZURE')),

    file_path VARCHAR(1000),
    checksum VARCHAR(255),
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_attachments_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
);

SELECT * FROM attachments;

CREATE TABLE checklist_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id BIGINT,
    title VARCHAR(255),
    completed BOOLEAN DEFAULT FALSE,
    completed_by BIGINT,
    completed_at TIMESTAMP,
    display_order INTEGER,

    CONSTRAINT fk_checklist_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
);

SELECT * FROM checklist_items;


CREATE TABLE comments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid CHAR(36) UNIQUE,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    comment TEXT NOT NULL,
    edited BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    deleted_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_comments_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);

SELECT * FROM comments;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE plan_members (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(20) DEFAULT 'MEMBER'
        CHECK (role IN ('OWNER','ADMIN','MEMBER','VIEWER')),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_plan_member UNIQUE (plan_id, user_id),

    CONSTRAINT fk_plan_members_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(id),

    CONSTRAINT fk_plan_members_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);

SELECT * FROM plan_members;


CREATE TABLE task_activity (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id BIGINT,
    activity_type VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    performed_by BIGINT,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_task_activity_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id)
);

SELECT * FROM task_activity;

CREATE TABLE task_labels (
    task_id BIGINT NOT NULL,
    label_id BIGINT NOT NULL,
    PRIMARY KEY (task_id, label_id),
    CONSTRAINT fk_task_labels_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(id),

    CONSTRAINT fk_task_labels_label
        FOREIGN KEY (label_id)
        REFERENCES labels(id)
);

SELECT * FROM task_labels;