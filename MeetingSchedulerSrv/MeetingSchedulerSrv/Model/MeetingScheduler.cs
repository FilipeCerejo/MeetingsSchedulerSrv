using System.ComponentModel.DataAnnotations;

namespace MeetingSchedulerSrv.Model;

public class MeetingScheduler
{
    [Required]
    public int meetingSchedulerId { get; set; }
    [Required]
    public string? name { get; set; }
    public string? description { get; set; }
    [StringLength(36)]
    public string? template { get; set; }
    public byte weekday { get; set; }
    [StringLength(4)]
    public string? hour { get; set; }
    public bool enabled { get; set; }
}
