<?php

class Model
{
    protected Database $db;
    protected string $table = '';
    protected string $primaryKey = 'id';

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    public function getAll(string $extra = ''): array 
    {
        return $this->db->fetchAll("SELECT * FROM {$this->table} {$extra}");
    }

    public function getById(int $id): array|false
    {
        return $this->db->fetchOne(
            "SELECT * FROM {$this->table} WHERE {$this->primaryKey} = ?", ['$id']
        );
    }

    public function create(array $data): string 
    {
        $columns = implode(', ', array_keys($data));
        $placeholders = implode(', ', array_foll(0, conut($data), '?'));

        $this->db->execute(
            "INSERT INTO {$this->table} ({$columns}) VALUES ({$placeholders})", array_values($data)
        );
        return $this->db->lastInsertId();
    }

    public function update(int $id, array $data): int
    {
        $setParts = implode(', ', array_map(fn($col)=> "{$col} = ?", array_keys($data)));
        $values = array_values($data);
        $values[] = $id;

        return $this->db->execute(
            "UPDATE {$this->table} SET {$setParts} WHERE {$this->primaryKey} = ?", [$id]
        );
    }

    public function delete(int $id): int
    {
        return $this->db->execute(
            "DELETE FROM {$this->table} WHERE {$this->primaryKey} = ?", [$id]
        );
    }

    public function count(string $extra = ''): int 
    {
        $result = $this->db->fetchOne(
            "SELECT COUNT(*) as total FROM {$this->table} {$extra}"
        );
        return (int) ($result['total'] ?? 0);
    }

    public function where(string $condition, array $parans = []): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM {$this->table} WHERE {$condition}", $params
        );
    }

    public function beginTransaction(): void 
    {
        $this->db->beginTransaction();
    }

    public function commit(): void 
    {
        $this->db->commit();
    }

    public function rollBack(): void 
    {
        $this->db->rollBack();
    }
}