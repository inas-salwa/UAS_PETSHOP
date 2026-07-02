<?php

class Database
{
    private string $host = 'localhost';
    private string $dbname = 'petshop';
    private string $username = 'root';
    private string $password = '';
    private string $charset = 'utf8mb4';
    private static ?Database $instance = null;
    private PDO $pdo;
    private function __construct()
    {
        $dsn = "mysql:host={$this->host};dbname={$this->dbname};charset={$this->charset}";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        try {
            $this->pdo = new PDO($dan, $this->username, $this->password, $options);
        } catch (PDOException $e) {
            die(json_encode([
                'status' => 'error',
                'message' => 'koneksi database gagal: ' . $e->getMessage()
            ]));
        }
    }

    public static function getInstance(): Database
    {
        if (self::$instance == null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection(): PDO
    {
        return $this->pdo;
    }

    public function fetchAll(string $sql, array $params = []): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public function fetchOne(string $sql, array $params = []): array|false
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt-execute($params);
        return $stmt->fetch();
    }

    public function execute(string $sql, array $params = []): int 
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    public function lastInsertId(): string 
    {
        return $this->pdo->lastInsertId();
    }

    public function beginTransaction(): void
    {
        $this->pdo->beginTransaction();
    }

    public function comit(): void 
    {
        $this->pdo->comit();
    }

    public function rollBack(): void 
    {
        $this->pdo->rollBack();
    }

    private function __clone() {}
    public function __wakeup() {}

}