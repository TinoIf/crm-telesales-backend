-- ================================================
-- CRM TELEMARKETING - DATABASE SCHEMA
-- PostgreSQL 15+
-- File: 001_init_schema.sql
-- Versi: 1.0 — 11 Mei 2026
-- ================================================

-- ================================================
-- EXTENSION
-- uuid-ossp menyediakan fungsi uuid_generate_v4()
-- untuk auto-generate UUID sebagai Primary Key.
-- ================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- 1. TABEL USERS
-- Menyimpan semua akun pengguna (Admin, BDM, Telesales)
-- ================================================
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL CHECK (role IN ('admin', 'bdm', 'telesales')),
    status        VARCHAR(20)  NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_role  ON users (role);

-- ================================================
-- 2. TABEL COMPANIES
-- Data profil perusahaan (entitas Parent).
-- UNIQUE pada name = inti fitur anti-duplikasi.
-- ================================================
CREATE TABLE companies (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(200) NOT NULL UNIQUE,
    industry    VARCHAR(100),
    address     TEXT,
    phone       VARCHAR(20),
    website     VARCHAR(255),
    assigned_to UUID         REFERENCES users(id) ON DELETE SET NULL,
    assigned_by UUID         REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ,
    created_by  UUID         NOT NULL REFERENCES users(id),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ  DEFAULT NULL
);

CREATE INDEX idx_companies_assigned_to ON companies (assigned_to);
CREATE INDEX idx_companies_name        ON companies (LOWER(name));
CREATE INDEX idx_companies_industry    ON companies (industry);
CREATE INDEX idx_companies_deleted_at  ON companies (deleted_at);

-- ================================================
-- 3. TABEL CONTACTS
-- Data kontak/prospect (entitas Child dari Company).
-- Satu Company bisa punya banyak Contact.
-- Status prospect di-track di level Contact.
-- ================================================
CREATE TABLE contacts (
    id                   UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id           UUID         NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name                 VARCHAR(100) NOT NULL,
    job_title            VARCHAR(100),
    phone                VARCHAR(20),
    email                VARCHAR(150),
    action_status        VARCHAR(30)  NOT NULL DEFAULT 'belum_dihubungi'
                         CHECK (action_status IN ('belum_dihubungi', 'sudah_dihubungi', 'tidak_bisa_dihubungi')),
    response_status      VARCHAR(30)
                         CHECK (response_status IN ('tertarik', 'ditolak', 'sudah_pakai_lain', 'belum_perlu', 'tidak_dibalas')),
    is_meeting_scheduled BOOLEAN      NOT NULL DEFAULT FALSE,
    created_by           UUID         NOT NULL REFERENCES users(id),
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at           TIMESTAMPTZ  DEFAULT NULL
);

CREATE INDEX idx_contacts_company_id      ON contacts (company_id);
CREATE INDEX idx_contacts_action_status   ON contacts (action_status);
CREATE INDEX idx_contacts_response_status ON contacts (response_status);
CREATE INDEX idx_contacts_meeting         ON contacts (is_meeting_scheduled);
CREATE INDEX idx_contacts_deleted_at      ON contacts (deleted_at);

-- ================================================
-- 4. TABEL CONTACT_ACTIVITIES
-- Log riwayat setiap aktivitas pada contact.
-- Terisi OTOMATIS oleh backend saat user update status.
-- ================================================
CREATE TABLE contact_activities (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id          UUID        NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    user_id             UUID        NOT NULL REFERENCES users(id),
    activity_type       VARCHAR(30) NOT NULL
                        CHECK (activity_type IN ('status_update', 'note_added', 'meeting_scheduled', 'contact_edited', 'contact_deleted')),
    channel             VARCHAR(20)
                        CHECK (channel IN ('call', 'whatsapp', 'email', 'visit')),
    old_action_status   VARCHAR(30),
    new_action_status   VARCHAR(30),
    old_response_status VARCHAR(30),
    new_response_status VARCHAR(30),
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activities_contact_id ON contact_activities (contact_id);
CREATE INDEX idx_activities_user_id    ON contact_activities (user_id);
CREATE INDEX idx_activities_created_at ON contact_activities (created_at DESC);

-- ================================================
-- 5. TABEL MEETINGS
-- Data jadwal meeting (status final dari alur leads).
-- ================================================
CREATE TABLE meetings (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id   UUID         NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    scheduled_by UUID         NOT NULL REFERENCES users(id),
    meeting_date DATE         NOT NULL,
    meeting_time TIME         NOT NULL,
    location     VARCHAR(255),
    agenda       TEXT,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meetings_date       ON meetings (meeting_date);
CREATE INDEX idx_meetings_contact_id ON meetings (contact_id);

-- ================================================
-- 6. TABEL ASSIGNMENT_LOGS
-- Riwayat assign/reassign company antar Telesales.
-- ================================================
CREATE TABLE assignment_logs (
    id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id   UUID        NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    from_user_id UUID        REFERENCES users(id),
    to_user_id   UUID        NOT NULL REFERENCES users(id),
    assigned_by  UUID        NOT NULL REFERENCES users(id),
    notes        TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assignment_logs_company ON assignment_logs (company_id);

-- ================================================
-- SEED DATA: Akun Admin Default
-- Password: admin123 (bcrypt hash)
-- Ganti hash ini dengan hasil bcrypt yang benar saat production
-- ================================================
-- INSERT INTO users (name, email, password_hash, role)
-- VALUES ('System Admin', 'admin@crm.local', '$2a$10$HASH_DISINI', 'admin');
