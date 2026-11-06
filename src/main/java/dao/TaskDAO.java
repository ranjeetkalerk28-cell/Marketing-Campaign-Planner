package dao;

import model.Task;
import util.DBConnection;

import java.sql.*;
import java.util.*;

/**
 * Data Access Object for Task entities.
 * All methods use PreparedStatement to prevent SQL injection.
 */
public class TaskDAO {

    // ── INSERT ───────────────────────────────────────────────────
    public void addTask(Task t) throws SQLException {
        String sql = "INSERT INTO tasks " +
                     "(campaign_id, title, type, deadline, cost, status, leads_generated) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, t.getCampaignId());
            ps.setString(2, t.getTitle());
            ps.setString(3, t.getType());
            ps.setDate  (4, t.getDeadline());
            ps.setDouble(5, t.getCost());
            ps.setString(6, t.getStatus());
            ps.setInt   (7, t.getLeadsGenerated());
            ps.executeUpdate();
        }
    }

    // ── SELECT BY CAMPAIGN ───────────────────────────────────────
    public List<Task> getTasksByCampaignId(int campaignId) throws SQLException {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE campaign_id = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── SELECT ALL WITH CAMPAIGN INFO (global task view) ─────────
    /**
     * Returns all tasks joined with campaign name, status, and budget.
     * Each map contains: id, campaignId, title, type, deadline, cost,
     * status, leadsGenerated, campaignName, campaignStatus, campaignBudget.
     */
    public List<Map<String, Object>> getAllTasksWithCampaign() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT t.id, t.campaign_id, t.title, t.type, t.deadline, " +
            "       t.cost, t.status, t.leads_generated, " +
            "       c.name AS campaign_name, c.status AS campaign_status, " +
            "       c.budget AS campaign_budget " +
            "FROM tasks t " +
            "JOIN campaigns c ON t.campaign_id = c.id " +
            "ORDER BY t.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",             rs.getInt("id"));
                row.put("campaignId",     rs.getInt("campaign_id"));
                row.put("title",          rs.getString("title"));
                row.put("type",           rs.getString("type"));
                row.put("deadline",       rs.getDate("deadline"));
                row.put("cost",           rs.getDouble("cost"));
                row.put("status",         rs.getString("status"));
                row.put("leadsGenerated", rs.getInt("leads_generated"));
                row.put("campaignName",   rs.getString("campaign_name"));
                row.put("campaignStatus", rs.getString("campaign_status"));
                row.put("campaignBudget", rs.getDouble("campaign_budget"));
                list.add(row);
            }
        }
        return list;
    }

    // ── AGGREGATE STATS ACROSS ALL TASKS ─────────────────────────
    /**
     * Returns aggregate metrics across ALL tasks and campaigns.
     * Keys: totalTasks, pending, inProgress, completed,
     *       totalCost, totalLeads, cpl, totalCampaigns
     */
    public Map<String, Object> getAllTaskStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql =
            "SELECT " +
            "  COUNT(*)                                                   AS totalTasks, " +
            "  SUM(CASE WHEN status='Pending'     THEN 1 ELSE 0 END)     AS pending, " +
            "  SUM(CASE WHEN status='In Progress' THEN 1 ELSE 0 END)     AS inProgress, " +
            "  SUM(CASE WHEN status='Completed'   THEN 1 ELSE 0 END)     AS completed, " +
            "  COALESCE(SUM(cost),0)                                      AS totalCost, " +
            "  COALESCE(SUM(leads_generated),0)                           AS totalLeads, " +
            "  COUNT(DISTINCT campaign_id)                                AS totalCampaigns " +
            "FROM tasks";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int    totalTasks     = rs.getInt("totalTasks");
                int    pending        = rs.getInt("pending");
                int    inProgress     = rs.getInt("inProgress");
                int    completed      = rs.getInt("completed");
                double totalCost      = rs.getDouble("totalCost");
                int    totalLeads     = rs.getInt("totalLeads");
                int    totalCampaigns = rs.getInt("totalCampaigns");
                double cpl            = totalLeads > 0 ? totalCost / totalLeads : 0.0;

                stats.put("totalTasks",     totalTasks);
                stats.put("pending",        pending);
                stats.put("inProgress",     inProgress);
                stats.put("completed",      completed);
                stats.put("totalCost",      totalCost);
                stats.put("totalLeads",     totalLeads);
                stats.put("cpl",            cpl);
                stats.put("totalCampaigns", totalCampaigns);
            }
        }
        return stats;
    }

    // ── SELECT BY ID ─────────────────────────────────────────────
    public Task getTaskById(int id) throws SQLException {
        String sql = "SELECT * FROM tasks WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ── UPDATE ───────────────────────────────────────────────────
    public void updateTask(Task t) throws SQLException {
        String sql = "UPDATE tasks " +
                     "SET title=?, type=?, deadline=?, cost=?, status=?, leads_generated=? " +
                     "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getType());
            ps.setDate  (3, t.getDeadline());
            ps.setDouble(4, t.getCost());
            ps.setString(5, t.getStatus());
            ps.setInt   (6, t.getLeadsGenerated());
            ps.setInt   (7, t.getId());
            ps.executeUpdate();
        }
    }

    // ── DELETE ───────────────────────────────────────────────────
    public void deleteTask(int id) throws SQLException {
        String sql = "DELETE FROM tasks WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── HELPER: campaign ID lookup before delete ─────────────────
    public int getCampaignIdByTaskId(int taskId) throws SQLException {
        String sql = "SELECT campaign_id FROM tasks WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("campaign_id");
            }
        }
        return -1;
    }

    // ── CALENDAR: tasks due in a given month ─────────────────────
    /**
     * Returns tasks (with campaign name) whose deadline falls in year/month.
     * Map keys: id, campaignId, title, type, deadline, cost, status,
     *           leadsGenerated, campaignName.
     */
    public List<Map<String, Object>> getTasksForMonth(int year, int month) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        java.time.LocalDate first = java.time.YearMonth.of(year, month).atDay(1);
        java.time.LocalDate last  = java.time.YearMonth.of(year, month).atEndOfMonth();
        String sql =
            "SELECT t.id, t.campaign_id, t.title, t.type, t.deadline, " +
            "       t.cost, t.status, t.leads_generated, " +
            "       c.name AS campaign_name " +
            "FROM tasks t " +
            "JOIN campaigns c ON t.campaign_id = c.id " +
            "WHERE t.deadline BETWEEN ? AND ? " +
            "ORDER BY t.deadline ASC, t.id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(first));
            ps.setDate(2, java.sql.Date.valueOf(last));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("id",             rs.getInt("id"));
                    row.put("campaignId",     rs.getInt("campaign_id"));
                    row.put("title",          rs.getString("title"));
                    row.put("type",           rs.getString("type"));
                    row.put("deadline",       rs.getDate("deadline"));
                    row.put("cost",           rs.getDouble("cost"));
                    row.put("status",         rs.getString("status"));
                    row.put("leadsGenerated", rs.getInt("leads_generated"));
                    row.put("campaignName",   rs.getString("campaign_name"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    // ── TODAY's TASKS ─────────────────────────────────────────────
    /**
     * Returns all tasks whose deadline = today's date, joined with campaign name.
     * Ordered so Pending and In-Progress appear before Completed.
     * Map keys: id, campaignId, title, type, deadline, cost, status,
     *           leadsGenerated, campaignName, campaignStatus.
     */
    public List<Map<String, Object>> getTodaysTasks() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT t.id, t.campaign_id, t.title, t.type, t.deadline, " +
            "       t.cost, t.status, t.leads_generated, " +
            "       c.name AS campaign_name, c.status AS campaign_status " +
            "FROM tasks t " +
            "JOIN campaigns c ON t.campaign_id = c.id " +
            "WHERE t.deadline = CURDATE() " +
            "ORDER BY FIELD(t.status,'Pending','In Progress','Completed'), t.id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new java.util.LinkedHashMap<>();
                row.put("id",             rs.getInt("id"));
                row.put("campaignId",     rs.getInt("campaign_id"));
                row.put("title",          rs.getString("title"));
                row.put("type",           rs.getString("type"));
                row.put("deadline",       rs.getDate("deadline"));
                row.put("cost",           rs.getDouble("cost"));
                row.put("status",         rs.getString("status"));
                row.put("leadsGenerated", rs.getInt("leads_generated"));
                row.put("campaignName",   rs.getString("campaign_name"));
                row.put("campaignStatus", rs.getString("campaign_status"));
                list.add(row);
            }
        }
        return list;
    }

    // ── ROW MAPPER ───────────────────────────────────────────────
    private Task mapRow(ResultSet rs) throws SQLException {
        Task t = new Task();
        t.setId            (rs.getInt   ("id"));
        t.setCampaignId    (rs.getInt   ("campaign_id"));
        t.setTitle         (rs.getString("title"));
        t.setType          (rs.getString("type"));
        t.setDeadline      (rs.getDate  ("deadline"));
        t.setCost          (rs.getDouble("cost"));
        t.setStatus        (rs.getString("status"));
        t.setLeadsGenerated(rs.getInt   ("leads_generated"));
        return t;
    }
}
