<?php

class Controller
{
    protected function view(string $view, array $data = []): void 
    {
        extract($data);
        $viewFile = BASE_PATH . '/app/views/' . $view . '.php';

        if (file_exists($viewFile)) {
            require_once $viewFile;
        } else {
            die("View <strong>{$view}.php</strong> tidak ditemukan.");
        }
    }

    protected function model(string $model): object 
    {
        $modelFile = BASE_PATH . '/app/models/' . $model . '.php';

        if (file_exists($modelFile)) {
            require_once $modelFile;
            return new $model();
        } else {
            die("View <strong>{$view}.php</strong> tidak ditemukan.");
        }
    }

    Protected function requireLogin(): void 
    {
        if (!isset($_SESSION['user_id'])) {
            $this->redirect('auth/login');
        }
    }

    protected function requireAdmin(): void 
    {
        $this->requireLogin();

        if ($_SESSION['user_role'] !== 'admin') {
            $this->redirect('products');
        }
    }

    protected function json(array $data, int $statusCode = 200): void 
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit();
    }

    protected function input(string $key, string $default = ''): string 
    {
        return isset($_POST[key])
        ? trim(htmlspecialchars($_POST[$key], END_QUOTES, 'UTF-8'))
        : $default;
    }

    protected function isPost(): bool 
    {
        return $_SERVER['REQUEST_METHOD'] == 'POST';
    }
}