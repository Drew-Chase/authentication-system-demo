<?php

namespace models;

use DateMalformedStringException;
use DateTime;
use Exception;
use Hashids\Hashids;
use JsonSerializable;
use Krixon\MultiFactorAuth\MultiFactorAuth;
use mysqli;

class User implements JsonSerializable
{
    private readonly int $id;
    private readonly string $email;
    private readonly string|null $password;
    private readonly DateTime $created;
    private readonly DateTime $last_online;
    private readonly string|null $mfa_secret;
    private readonly bool $password_reset_request;

    /**
     * Initializes a new instance of the class with the provided user data.
     *
     * @param int $id The unique identifier of the user.
     * @param string $email The email of the user.
     * @param string|null $password The password of the user, or null if not set.
     * @param DateTime $created The date and time when the user's account was created.
     * @param DateTime $last_online The date and time when the user was last online.
     * @param string|null $mfa_secret The multi-factor authentication secret for the user, or null if not set.
     * @param bool $password_reset_request Indicates whether the user has requested a password reset.
     * @return void
     */
    public function __construct(int $id, string $email, string|null $password, DateTime $created, DateTime $last_online, string|null $mfa_secret, bool $password_reset_request)
    {
        $this->id = $id;
        $this->email = $email;
        $this->password = $password;
        $this->created = $created;
        $this->last_online = $last_online;
        $this->mfa_secret = $mfa_secret;
        $this->password_reset_request = $password_reset_request;
    }

    /**
     * Retrieves a list of users from the database.
     *
     * @param mysqli $db The database connection object.
     * @return User[] Returns an array of User objects populated with data from the database.
     * @throws DateMalformedStringException
     */
    public static function getUsers(mysqli $db): array
    {
        $result = $db->query("SELECT * FROM users");
        $items = $result->fetch_all();
        $users = array();
        foreach ($items as $item)
        {
            $user = new User(
                $item['id'],
                $item['email'],
                $item['password'],
                new DateTime($item['created']),
                new DateTime($item['last_online']),
                $item['mfa_secret'],
                $item['password_reset_request']
            );
            $users[] = $user;
        }
        return $users;
    }

    /**
     * @throws DateMalformedStringException
     */
    public static function getUserById(mysqli $db, int $id): User
    {
        $stmt = $db->prepare("SELECT * FROM users WHERE id = ? LIMIT 1");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $item = $result->fetch_all()[0];
        return new User(
            $item['id'],
            $item['email'],
            $item['password'],
            new DateTime($item['created']),
            new DateTime($item['last_online']),
            $item['mfa_secret'],
            $item['password_reset_request']
        );

    }

    /**
     * @throws DateMalformedStringException
     */
    public static function createUser(mysqli $db, string $email, string $password): User
    {
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $db->prepare("INSERT INTO users (email, password) VALUES (?,?)");
        $stmt->bind_param('ss', $email, $hashed_password);
        $stmt->execute();
        $stmt->close();
        $last_id = $db->insert_id;
        return self::getUserById($db, $last_id);
    }

    public function registerMFA(mysqli $db):void{
        $mfa = MultiFactorAuth::default(getenv("APP_NAME"));
        $secret = $mfa->generateSecret();
        $stmt = $db->prepare("UPDATE users SET mfa_secret = ? WHERE id = ?");
        $stmt->bind_param('si', $secret, $id);
        $stmt->execute();
        $stmt->close();
    }

    /**
     * Specifies the data to be serialized into JSON format.
     *
     * @return array An associative array containing the serialized representation of the object, including:
     *               - "id": Encoded identifier of the object.
     *               - "username": Username associated with the object.
     *               - "last_online": Timestamp of the user's last online activity.
     *               - "created": Timestamp of when the object was created.
     */
    public function jsonSerialize(): array
    {
        $hashid = self::getHashId();
        return ["id" => $hashid->encode($this->id), "email" => $this->email, "last_online" => $this->last_online, "created" => $this->created];
    }

    /**
     * Converts a JSON array into a User object.
     *
     * @param array $obj The JSON array containing user data.
     * @return User Returns an instance of the User class populated with the provided data.
     * @throws Exception Throws an exception if the hashed ID is not valid.
     */
    public static function fromObj(array $obj): User
    {
        $hashid = self::getHashId();
        $id = $obj["id"];
        if (is_string($id))
        {
            $id = $hashid->decode($id);
            if (count($id) != 1)
            {
                throw new Exception("The hashed id is not valid");
            }
            $id = $id[0];
        }
        $username = $obj["email"];
        $lastOnline = new DateTime($obj["last_online"]);
        $created = new DateTime($obj["created"]);
        $password = $obj["password"] ?? "";
        $mfaSecret = $obj["mfa_secret"];
        $resetRequest = $obj["password_reset_request"] ?? false;
        return new self($id, $username, $password, $created, $lastOnline, $mfaSecret, $resetRequest);
    }

    private static function getHashId(): Hashids
    {
        $salt = getenv("USER_ID_SALT");
        return new Hashids($salt, 6);
    }
    private function render_php(string $template): string
    {
        ob_start();
        include(__DIR__ . "/api/templates/$template.php");
        $contents = ob_get_contents();
        ob_end_clean();
        return $contents;
    }
}