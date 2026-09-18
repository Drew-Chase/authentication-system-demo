<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../set_root.php';

use Slim\Factory\AppFactory;
use Slim\Psr7\Request;
use Slim\Psr7\Response;

$dotenv = Dotenv\Dotenv::createImmutable($_SERVER["DOCUMENT_ROOT"]);
// This will suppress exceptions if the .env file is not present.
// This is good for production where you would normally use the env in the docker container or in the systemd service.
$dotenv->safeLoad();

$app = AppFactory::create();
$app->addRoutingMiddleware();
$app->setBasePath("/api");

// Replace Slim's default HTML error handler with JSON
$errorMiddleware = $app->addErrorMiddleware(false, true, true);
$errorMiddleware->setDefaultErrorHandler(
    function (
        Request   $request,
        Throwable $exception,
        bool      $displayErrorDetails,
        bool      $logErrors,
        bool      $logErrorDetails
    ) use ($app): Response
    {
        $payload = [
            'error' => $exception->getMessage(),
        ];

        if ($displayErrorDetails)
        {
            $payload['stacktrace'] = $exception->getTrace();
        }

        $response = $app->getResponseFactory()->createResponse();

        $response->getBody()->write(
            json_encode($payload, JSON_PRETTY_PRINT)
        );

        return $response
            ->withStatus(500)
            ->withHeader('Content-Type', 'application/json');
    }
);

// ENDPOINTS


$app->run();