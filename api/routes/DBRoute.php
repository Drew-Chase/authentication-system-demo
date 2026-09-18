<?php

namespace routes;

use Exception;
use mysqli;
use mysqli_sql_exception;

class DBRoute
{
    protected static mysqli $db;

    /**
     * Establishes and returns a MySQL database connection.
     * If a singleton connection is already set, it will return the existing connection.
     * Reads the database connection credentials from an environment file.
     * Throws an exception if the connection fails or if there is an error during the connection process.
     * The character set for the connection is explicitly set to UTF-8.
     *
     * @return mysqli The active MySQL database connection instance.
     * @throws Exception If the connection to the MySQL database fails.
     */
    protected function connect_db(): mysqli
    {
        if (isset(DBRoute::$db)) return DBRoute::$db; // If the singleton is set, return it instead of creating a new connection

        // Fetch the connection credentials from the env file
        $DATABASE_HOST = getenv("DATABASE_HOST");
        $DATABASE_USERNAME = getenv("DATABASE_USERNAME");
        $DATABASE_PASSWORD = getenv("DATABASE_PASSWORD");
        $DATABASE_NAME = getenv("DATABASE_NAME");
        $DATABASE_PORT = getenv("DATABASE_PORT");

        try
        {
            $db = mysqli_connect($DATABASE_HOST, $DATABASE_USERNAME, $DATABASE_PASSWORD, $DATABASE_NAME, $DATABASE_PORT);
        } catch (mysqli_sql_exception $e)
        {
            throw new mysqli_sql_exception("Could not connect to database: " . $e->getMessage());
        } catch (Exception $e)
        {
            throw new Exception("Unknown error while trying to connect to database: " . $e->getMessage());
        }
        $db->set_charset("utf8mb4"); // Set the character set explicitly, the default character set can sometimes break special characters in passwords and emails!
        return DBRoute::$db = $db;
    }
}