package model;

import java.sql.Date;

/**
 * Represents a single task linked to a marketing campaign.
 */
public class Task {

    private int    id;
    private int    campaignId;
    private String title;
    private String type;    // e.g. Design | Launch | Content | Research
    private Date   deadline;
    private double cost;
    private String status;          // Pending | In Progress | Completed
    private int    leadsGenerated;  // leads attributed to this task

    // ── Constructors ────────────────────────────────────────────
    public Task() {}

    public Task(int id, int campaignId, String title, String type,
                Date deadline, double cost, String status, int leadsGenerated) {
        this.id             = id;
        this.campaignId     = campaignId;
        this.title          = title;
        this.type           = type;
        this.deadline       = deadline;
        this.cost           = cost;
        this.status         = status;
        this.leadsGenerated = leadsGenerated;
    }

    // ── Getters & Setters ────────────────────────────────────────
    public int  getId()          { return id; }
    public void setId(int id)    { this.id = id; }

    public int  getCampaignId()              { return campaignId; }
    public void setCampaignId(int campaignId){ this.campaignId = campaignId; }

    public String getTitle()              { return title; }
    public void   setTitle(String title)  { this.title = title; }

    public String getType()             { return type; }
    public void   setType(String type)  { this.type = type; }

    public Date getDeadline()               { return deadline; }
    public void setDeadline(Date deadline)  { this.deadline = deadline; }

    public double getCost()              { return cost; }
    public void   setCost(double cost)   { this.cost = cost; }

    public String getStatus()               { return status; }
    public void   setStatus(String status)  { this.status = status; }

    public int  getLeadsGenerated()                  { return leadsGenerated; }
    public void setLeadsGenerated(int leadsGenerated){ this.leadsGenerated = leadsGenerated; }
}
