package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for JDBC connection.
 * Uses MySQL Connector/J 8.x with Tomcat 9 (javax.servlet).
 */
public class DBConnection {

    private static final String URL =
        "jdbc:mysql://localhost:3306/marketing_db" +
        "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "279279";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "MySQL JDBC Driver not found on classpath: " + e.getMessage());
        }
    }

    /** Returns a new connection from DriverManager. Caller must close it. */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private DBConnection() {}
}
