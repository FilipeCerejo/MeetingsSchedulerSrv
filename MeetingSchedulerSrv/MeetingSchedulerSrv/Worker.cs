using MeetingSchedulerSrv.Model;
using MeetingSchedulerSrv.Data;

namespace MeetingSchedulerSrv;

public class Worker : BackgroundService
{
    private readonly IConfiguration _config;
    private readonly SqlDataAccess _db;

    public Worker(IConfiguration config, SqlDataAccess db)
    {
        _config = config;
        _db = db;

        //alter table MeetingScheduler add constraint [chk_weekaday] check([weekday] >= 1 and [weekday] <= 7) 
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            List<MeetingScheduler> meetings = GetMeetingSchedulers();

            foreach (MeetingScheduler meetingSch in meetings)
            {
                CloseMeetings(meetingSch.meetingSchedulerId);

                if (meetingSch.enabled)
                {
                    DateTime nextMeetingRun = GetNextMeetingRunDate(meetingSch.weekday, meetingSch.hour);

                    bool existsMeeting = ExistsMeetingScheduled(meetingSch.meetingSchedulerId, nextMeetingRun);
                    if (!existsMeeting)
                    {
                        CreateMeeting(meetingSch, nextMeetingRun);
                    }
                }
            }

            DateTime nextRunTicks = CalculateNextRun();

            await Task.Delay(new TimeSpan(nextRunTicks.Ticks - DateTime.Now.Ticks), stoppingToken);
        }
    }

    private void CreateMeeting(MeetingScheduler meetingSch, DateTime nextMeetingRun)
    {
        _db.ExecProc("sp_meeting_insert", new { name = meetingSch.name, description = meetingSch.description, date = nextMeetingRun, scheduleId = meetingSch.meetingSchedulerId });
    }

    private bool ExistsMeetingScheduled(int schedulerId, DateTime nextDate)
    {
        return _db.ExistsProc("sp_exists_meeting", new { meetingSchedulerId = schedulerId, date = nextDate });
    }

    private void CloseMeetings(int schedulerId)
    {
        _db.ExecProc("sp_close_meeting_by_schduler",
                    new { meetingSchedulerId = schedulerId, hours = _config.GetValue<int>("HoursToClose") });
    }

    private List<MeetingScheduler> GetMeetingSchedulers()
    {
        return _db.LoadDataProc<MeetingScheduler, dynamic>("sp_get_meetingscheduler", new { });
    }

    private DateTime GetNextMeetingRunDate(byte weekday, string hm)
    {
        if(hm.Length != 4) { throw new Exception(string.Format("Hora e Minutos mal introduzida: {0}", hm)); }

        DateTime n = DateTime.Now;
        DayOfWeek wd =  (DayOfWeek)Enum.Parse(typeof(DayOfWeek), (weekday - 1).ToString());

        while(n.DayOfWeek != wd)
        {
            n = n.AddDays(1);
        }

        return new DateTime(n.Year, n.Month, n.Day, int.Parse(hm.Substring(0, 2)), int.Parse(hm.Substring(2, 2)), 0);
    }

    private DateTime CalculateNextRun()
    {
        DateTime now = DateTime.Now;
        DateTime nextRun;

        if(now.Hour >= 12)
        {
            now = now.AddDays(1);    
        }

        nextRun = new DateTime(now.Year, now.Month, now.Day, (now.Hour < 12 ? 12 : 0), 0, 0);

        return nextRun;
    }
}
