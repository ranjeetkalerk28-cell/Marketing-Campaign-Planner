package model;

import java.sql.Date;

/**
 * Represents a marketing campaign.
 * The {@code leads} field is automatically maintained as the
 * SUM of leads_generated across all linked tasks.
 */
public class Campaign {

    private int    id;
    private String name;
    private String description;
    private Date   startDate;
    private Date   endDate;
    private double budget;
    private String type;    // Email | Ads | Social Media
    private String status;  // Planned | Active | Completed
    private int    leads;   // auto-synced from tasks

    // ── Constructors ────────────────────────────────────────────
    public Campaign() {}

    public Campaign(int id, String name, String description,
                    Date startDate, Date endDate,
                    double budget, String type, String status, int leads) {
        this.id          = id;
        this.name        = name;
        this.description = description;
        this.startDate   = startDate;
        this.endDate     = endDate;
        this.budget      = budget;
        this.type        = type;
        this.status      = status;
        this.leads       = leads;
    }

    // ── Getters & Setters ────────────────────────────────────────
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }

    public String getName()             { return name; }
    public void   setName(String name)  { this.name = name; }

    public String getDescription()                  { return description; }
    public void   setDescription(String description){ this.description = description; }

    public Date getStartDate()               { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate()             { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public double getBudget()              { return budget; }
    public void   setBudget(double budget) { this.budget = budget; }

    public String getType()             { return type; }
    public void   setType(String type)  { this.type = type; }

    public String getStatus()               { return status; }
    public void   setStatus(String status)  { this.status = status; }

    public int  getLeads()            { return leads; }
    public void setLeads(int leads)   { this.leads = leads; }
}
