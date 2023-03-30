using MeetingSchedulerSrv;
using MeetingSchedulerSrv.Data;

IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services =>
    {
        services.AddHostedService<Worker>();
        services.AddTransient<SqlDataAccess>();
    })
    .Build();

await host.RunAsync();
