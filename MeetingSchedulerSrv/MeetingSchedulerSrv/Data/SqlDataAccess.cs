using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace MeetingSchedulerSrv.Data;
public class SqlDataAccess
{
    private readonly IConfiguration _config;
    public string ConnectionStringName { get; set; } = "Default";

    public SqlDataAccess(IConfiguration config)
    {
        _config = config;
    }

    public bool ExistsProc<U>(string sql, U parameters)
    {
        string? connectionString = _config.GetConnectionString(ConnectionStringName);

        using(IDbConnection connection = new SqlConnection(connectionString))
        {
            var result = connection.ExecuteScalar<int>(sql, parameters, commandType: CommandType.StoredProcedure);
            return result != 0;
        }
    }

    public List<T> LoadDataProc<T, U>(string sql, U parameters)
    {
        string? connectionString = _config.GetConnectionString(ConnectionStringName);

        using(IDbConnection connection = new SqlConnection(connectionString))
        {
            var data = connection.Query<T>(sql, parameters, commandType: CommandType.StoredProcedure);
            return data.ToList();
        }
    }

    public void ExecProc<U>(string sql, U parameters)
    {
        string? connectionString = _config.GetConnectionString(ConnectionStringName);

        using (IDbConnection connection = new SqlConnection(connectionString))
        {
            connection.Execute(sql, parameters, commandType: CommandType.StoredProcedure);
        }
    }
}
