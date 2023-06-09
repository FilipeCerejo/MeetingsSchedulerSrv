USE [master]
GO
/****** Object:  Database [Mees]    Script Date: 30/03/2023 15:44:56 ******/
CREATE DATABASE [Mees]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Mees', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Mees.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Mees_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Mees_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Mees] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Mees].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Mees] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Mees] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Mees] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Mees] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Mees] SET ARITHABORT OFF 
GO
ALTER DATABASE [Mees] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Mees] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Mees] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Mees] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Mees] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Mees] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Mees] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Mees] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Mees] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Mees] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Mees] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Mees] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Mees] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Mees] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Mees] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Mees] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Mees] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Mees] SET RECOVERY FULL 
GO
ALTER DATABASE [Mees] SET  MULTI_USER 
GO
ALTER DATABASE [Mees] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Mees] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Mees] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Mees] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Mees] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Mees', N'ON'
GO
ALTER DATABASE [Mees] SET QUERY_STORE = OFF
GO
USE [Mees]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [Mees]
GO
/****** Object:  Table [dbo].[Meeting]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Meeting](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NULL,
	[description] [varchar](511) NULL,
	[date] [datetime] NULL,
	[status] [int] NULL,
	[scheduleId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MeetingScheduler]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MeetingScheduler](
	[meetingSchedulerId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NOT NULL,
	[description] [varchar](511) NULL,
	[template] [uniqueidentifier] NULL,
	[weekday] [smallint] NULL,
	[hour] [char](4) NULL,
	[enabled] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[meetingSchedulerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Meeting]  WITH CHECK ADD FOREIGN KEY([scheduleId])
REFERENCES [dbo].[MeetingScheduler] ([meetingSchedulerId])
GO
ALTER TABLE [dbo].[MeetingScheduler]  WITH CHECK ADD  CONSTRAINT [chk_weekaday] CHECK  (([weekday]>=(1) AND [weekday]<=(7)))
GO
ALTER TABLE [dbo].[MeetingScheduler] CHECK CONSTRAINT [chk_weekaday]
GO
/****** Object:  StoredProcedure [dbo].[sp_close_meeting_by_schduler]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_close_meeting_by_schduler] (
	  @meetingSchedulerId int
	, @hours smallint
) as begin

	update m set status = 2
	from Meeting m
	where scheduleId = @meetingSchedulerId
	and date < dateadd(hh, - (@hours), current_timestamp)
	

end
GO
/****** Object:  StoredProcedure [dbo].[sp_exists_meeting]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_exists_meeting] (
	  @meetingSchedulerId int
	, @date datetime
) as begin

	select 1
	from Meeting
	where scheduleId = @meetingSchedulerId
	and datediff(mi, date, @date) < 1;

end
GO
/****** Object:  StoredProcedure [dbo].[sp_get_meetingscheduler]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_meetingscheduler] 
as begin
	select 
		  [meetingSchedulerId]
		, [name]
		, [description]
		, convert(nvarchar(36), [template]) [template]
		, [weekday]
		, [hour]
		, [enabled]
	from MeetingScheduler
end
GO
/****** Object:  StoredProcedure [dbo].[sp_meeting_insert]    Script Date: 30/03/2023 15:44:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_meeting_insert] (
	@name varchar(255),
	@description varchar(511),
	@date datetime,
	@scheduleId int
) as begin

	insert into Meeting values (@name, @description, @date, 1, @scheduleId)

end
GO
USE [master]
GO
ALTER DATABASE [Mees] SET  READ_WRITE 
GO
