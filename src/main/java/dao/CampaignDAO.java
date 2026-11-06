package dao;

import model.Campaign;
import util.DBConnection;

import java.sql.*;
import java.util.*;

/**
 * Data Access Object for Campaign entities.
 * All methods use PreparedStatement to prevent SQL injection.
 */
public class CampaignDAO {

    // ── INSERT ───────────────────────────────────────────────────
    public void insertCampaign(Campaign c) throws SQLException {
        String sql = "INSERT INTO campaigns " +
                     "(name, description, start_date, end_date, budget, type, status, leads) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getDescription());
            ps.setDate  (3, c.getStartDate());
            ps.setDate  (4, c.getEndDate());
            ps.setDouble(5, c.getBudget());
            ps.setString(6, c.getType());
            ps.setString(7, c.getStatus());
            ps.executeUpdate();
        }
    }

    // ── SELECT ALL ───────────────────────────────────────────────
    public List<Campaign> getAllCampaigns() throws SQLException {
        List<Campaign> list = new ArrayList<>();
        String sql = "SELECT * FROM campaigns ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── SELECT BY ID ─────────────────────────────────────────────
    public Campaign getCampaignById(int id) throws SQLException {
        String sql = "SELECT * FROM campaigns WHERE id = ?";
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
    public void updateCampaign(Campaign c) throws SQLException {
        String sql = "UPDATE campaigns " +
                     "SET name=?, description=?, start_date=?, end_date=?, " +
                     "    budget=?, type=?, status=? " +
                     "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getDescription());
            ps.setDate  (3, c.getStartDate());
            ps.setDate  (4, c.getEndDate());
            ps.setDouble(5, c.getBudget());
            ps.setString(6, c.getType());
            ps.setString(7, c.getStatus());
            ps.setInt   (8, c.getId());
            ps.executeUpdate();
        }
    }

    // ── DELETE ───────────────────────────────────────────────────
    public void deleteCampaign(int id) throws SQLException {
        // Tasks are deleted by ON DELETE CASCADE in the schema
        String sql = "DELETE FROM campaigns WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── SYNC LEAD COUNT ──────────────────────────────────────────
    /**
     * Re-calculates and persists the campaign's lead total from its tasks.
     * Called automatically after any task insert / update / delete.
     */
    public void updateLeads(int campaignId) throws SQLException {
        String sql = "UPDATE campaigns " +
                     "SET leads = (SELECT COALESCE(SUM(leads_generated), 0) " +
                     "             FROM tasks WHERE campaign_id = ?) " +
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setInt(2, campaignId);
            ps.executeUpdate();
        }
    }

    // ── DASHBOARD STATS ─────────────────────────────────────────
    /**
     * Returns aggregated metrics used by the dashboard:
     *   total, active, completed, totalBudget, totalLeads, cpl
     */
    public Map<String, Object> getDashboardStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql =
            "SELECT " +
            "  COUNT(*)                                               AS total, " +
            "  SUM(CASE WHEN status='Active'    THEN 1 ELSE 0 END)   AS active, " +
            "  SUM(CASE WHEN status='Completed' THEN 1 ELSE 0 END)   AS completed, " +
            "  SUM(CASE WHEN status='Planned'   THEN 1 ELSE 0 END)   AS planned, " +
            "  COALESCE(SUM(budget), 0)                              AS totalBudget, " +
            "  COALESCE(SUM(leads),  0)                              AS totalLeads " +
            "FROM campaigns";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int    total       = rs.getInt("total");
                int    active      = rs.getInt("active");
                int    completed   = rs.getInt("completed");
                int    planned     = rs.getInt("planned");
                double totalBudget = rs.getDouble("totalBudget");
                int    totalLeads  = rs.getInt("totalLeads");
                double cpl         = (totalLeads > 0) ? totalBudget / totalLeads : 0.0;

                stats.put("total",       total);
                stats.put("active",      active);
                stats.put("completed",   completed);
                stats.put("planned",     planned);
                stats.put("totalBudget", totalBudget);
                stats.put("totalLeads",  totalLeads);
                stats.put("cpl",         cpl);
            }
        }
        return stats;
    }

    // ── CALENDAR: campaigns overlapping a month ──────────────────
    /**
     * Returns all campaigns whose date range overlaps the given month.
     * A campaign overlaps when: start_date <= lastDayOfMonth AND end_date >= firstDayOfMonth.
     */
    public List<Campaign> getCampaignsForMonth(int year, int month) throws SQLException {
        List<Campaign> list = new ArrayList<>();
        // First and last day of the requested month
        java.time.LocalDate first = java.time.YearMonth.of(year, month).atDay(1);
        java.time.LocalDate last  = java.time.YearMonth.of(year, month).atEndOfMonth();
        String sql =
            "SELECT * FROM campaigns " +
            "WHERE start_date <= ? AND end_date >= ? " +
            "ORDER BY start_date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(last));
            ps.setDate(2, java.sql.Date.valueOf(first));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── ROW MAPPER ───────────────────────────────────────────────
    private Campaign mapRow(ResultSet rs) throws SQLException {
        Campaign c = new Campaign();
        c.setId         (rs.getInt   ("id"));
        c.setName       (rs.getString("name"));
        c.setDescription(rs.getString("description"));
        c.setStartDate  (rs.getDate  ("start_date"));
        c.setEndDate    (rs.getDate  ("end_date"));
        c.setBudget     (rs.getDouble("budget"));
        c.setType       (rs.getString("type"));
        c.setStatus     (rs.getString("status"));
        c.setLeads      (rs.getInt   ("leads"));
        return c;
    }
}
