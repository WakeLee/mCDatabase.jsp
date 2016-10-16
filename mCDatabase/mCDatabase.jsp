<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ page import="net.sf.json.JSONObject" %> 
<%@ page import="net.sf.json.JSONArray" %> 
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.File" %> 
<%@ page import="java.io.PrintWriter" %> 
<%@ page import="java.io.FileOutputStream" %> 
<%@ page import="java.io.OutputStreamWriter" %> 
<%@ page import="java.io.BufferedWriter" %> 
<%@ page import="java.io.IOException" %> 
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.ParseException" %>

<%!
// 作者: 李辙
// 找我: wakelee.coderwriter.com
// Author: Wake Lee
// FindMe: wakelee.coderwriter.com
public class mCDatabase_base
{
	HttpServletRequest request = null;
	HttpServletResponse response = null;
	PrintWriter out = null;
	
	String dbtype = "";
	Statement stmt = null;
	
	boolean bLog = true;
	String sLogPath = "";
	public void SetLog(boolean _bLog, String _sLogPath)
	{
		bLog = _bLog;
		sLogPath = _sLogPath;
	}
		
	void Show(String tip)
	{
		String html = "";
		html += "<div style='background-color:#b22222;color:#ffffe0;font-size:24px;padding:10px;margin:10px 0px;'>";
		html += tip;
		html += "</div>";
		
		out.println(html);
		
		if(bLog)
		{
			try
			{
		        String sAbsolutePath = request.getSession().getServletContext().getRealPath("/") + sLogPath;
				
				File folder = new File(sAbsolutePath + "/mCDatabase-logs");
				if( !folder.exists() ) folder.mkdir();

				FileOutputStream stream = new FileOutputStream(sAbsolutePath + "/mCDatabase-logs/mCDatabase-log-" + DateToStr() + ".txt", true);
				OutputStreamWriter writer = new OutputStreamWriter(stream, "UTF-8");   
				BufferedWriter buffer = new BufferedWriter(writer); 
				buffer.write("[ " + DateTimeToStr() + " ] [ " + GetUrl(request) + " ] [ " + tip + " ]\r\n");
				buffer.close();
				writer.close();
				stream.close();
			}
			catch(IOException e)
			{
				out.println(e);
			}
		}
	}
	
	int ErrorCode = 0;
	boolean IsError(String tip)
	{
		switch(ErrorCode)
		{
			case 0: break;
			
			case 1: Show("Error : open connection error " + tip); break;
			case 2: Show("Error : close connection error " + tip); break;
			
			case 3: Show("Error : open recordset error " + tip); break;
			case 4: Show("Error : close recordset error " + tip); break;
			
			case 5: Show("Error : insert error " + tip); break;
			case 6: Show("Error : delete error " + tip); break;
			case 7: Show("Error : update error " + tip); break;
			case 8: Show("Error : query error " + tip); break;
			
			case 9: Show("Error : get record total count error " + tip); break;
			case 10: Show("Error : get field total count error " + tip); break;
			case 11: Show("Error : get field name error " + tip); break;
			
			case 12: Show("Error : get int error " + tip); break;
			case 13: Show("Error : get double error " + tip); break;
			case 14: Show("Error : get string error " + tip); break;
			case 15: Show("Error : get datetime error " + tip); break;
			
			case 16: Show("Error : move next error " + tip); break;
			
			case 17: Show("Error : driver error " + tip); break;
		}
		
		return ErrorCode == 0 ? false : true;
	}
	
	String DateTimeToStr()
	{
		return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format( new Date().getTime() );
	}
	String DateToStr()
	{
		return new SimpleDateFormat("yyyy-MM-dd").format( new Date().getTime() );
	}
	String GetUrl(HttpServletRequest request)
	{
		String host = request.getScheme();
		String url = request.getHeader("Host") + request.getRequestURI();
		String str = request.getQueryString() == null ? "" : request.getQueryString();
		
		String full_url = host + "://" + url;
		if(str != "") full_url += "?" + str;
		
		return full_url;
	}
}

// 记录集类
// Recordset class
public class CRs extends mCDatabase_base
{
	ResultSet rs = null;
	public boolean eof = true;
	
	JSONArray kvs = new JSONArray(); // key/value array
	String where = "";
	
	public CRs(HttpServletRequest _request, HttpServletResponse _response, PrintWriter _out, int _ErrorCode, String _dbtype, Statement _stmt, boolean _bLog, String _sLogPath)
	{
		request = _request;
		response = _response;
		out = _out;
		ErrorCode = _ErrorCode;
		dbtype = _dbtype;
		stmt = _stmt;
		bLog = _bLog;
		sLogPath = _sLogPath;
	}

	// 增
	// Insert
	public void Insert(String table)
	{
		if( IsError("Insert()") ) return;
		
		int count = kvs.size();
		
		String sql = "insert into " + table;
		sql += "(";
		for(int i = 0; i < count; i++)
		{
			sql += kvs.getJSONObject(i).getString("key");
			if(i != count - 1) sql += ",";
		}
		sql += ")";
		sql += "values";
		sql += "(";
		for(int i = 0; i < count; i++)
		{
			switch( kvs.getJSONObject(i).getString("type") )
			{
				case "int": sql += kvs.getJSONObject(i).getString("value"); break;
				case "String": sql += "'" + kvs.getJSONObject(i).getString("value") + "'"; break;
			}
			
			if(i != count - 1) sql += ",";
		}
		sql += ")";
		
		try
		{
			stmt.executeUpdate(sql);;
		}
		catch(SQLException e)
		{
			ErrorCode = 5;
			if( IsError("Insert() " + e) ) return;
		}
	}

	// 删
	// Delete
	public void Delete(String table)
	{
		if( IsError("Delete()") ) return;
		
		try
		{
			String sql = "delete from " + table + " where " + where;
			stmt.executeUpdate(sql);;
		}
		catch(SQLException e)
		{
			ErrorCode = 6;
			if( IsError("Delete() " + e) ) return;
		}
	}

	// 改
	// Update
	public void Update(String table)
	{
		if( IsError("Update()") ) return;
		
		int count = kvs.size();

		String sql = "update " + table + " set ";
		for(int i = 0; i < count; i++)
		{
			switch( kvs.getJSONObject(i).getString("type") )
			{
				case "int": sql += kvs.getJSONObject(i).getString("key") + "=" + kvs.getJSONObject(i).getString("value"); break;
				case "String": sql += kvs.getJSONObject(i).getString("key") + "=" + "'" + kvs.getJSONObject(i).getString("value") + "'"; break;
			}
			
			if(i != count - 1) sql += ",";
		}
		sql += " where " + where;
		
		try
		{
			stmt.executeUpdate(sql);;
		}
		catch(SQLException e)
		{
			ErrorCode = 7;
			if( IsError("Update() " + e) ) return;
		}
	}

	// 查
	// Query
	public void Query(String sql)
	{
		if( IsError("Query()") ) return;
		
		try
		{
			rs = stmt.executeQuery(sql);
		}
		catch(SQLException e)
		{
			ErrorCode = 8;
			if( IsError("OpenRs() " + e) ) return;
		}
		
		try
		{
			eof = !rs.next();
		}
		catch(SQLException e)
		{
			ErrorCode = 16;
			if( IsError("OpenRs() " + e) ) return;
		}
	}
	
	public void SetInt(String key, int value)
	{
		JSONObject kv = new JSONObject();
		kv.put("key", key);
		kv.put("value", value);
		kv.put("type", "int");
		kvs.add(kv);
	}
	public void SetDouble(String key, double value)
	{
		JSONObject kv = new JSONObject();
		kv.put("key", key);
		kv.put("value", "" + value);
		kv.put("type", "String");
		kvs.add(kv);
	}
	public void SetString(String key, String value)
	{
		JSONObject kv = new JSONObject();
		kv.put("key", key);
		kv.put("value", value);
		kv.put("type", "String");
		kvs.add(kv);
	}
	public void SetDateTime(String key, String value)
	{
		if(value == "") value = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format( new Date().getTime() );
		
		JSONObject kv = new JSONObject();
		kv.put("key", key);
		kv.put("value", value);
		kv.put("type", "String");
		kvs.add(kv);
	}
	
	public int GetInt(String key)
	{
		int value = 0;
		if( IsError("GetInt()") ) return value;
		
		try
		{
			value = rs.getInt(key);
		}
		catch(SQLException e)
		{
			ErrorCode = 12;
			if( IsError("GetInt() " + e) ) return value;
		}
		
		return value;
	}
	public double GetDouble(String key)
	{
		double value = 0;
		if( IsError("GetDouble()") ) return value;
		
		try
		{
			value = rs.getDouble(key);
		}
		catch(SQLException e)
		{
			ErrorCode = 13;
			if( IsError("GetDouble() " + e) ) return value;
		}
		
		return value;
	}
	public String GetString(String key)
	{
		String value = "";
		if( IsError("GetString()") ) return value;
		
		try
		{
			value = rs.getString(key);
		}
		catch(SQLException e)
		{
			ErrorCode = 14;
			if( IsError("GetString() " + e) ) return value;
		}
		
		return value;
	}
	public String GetDateTime(String key)
	{
		String value = "";
		if( IsError("GetDateTime()") ) return value;
		
		try
		{
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			value = format.format( format.parse( rs.getString(key) ).getTime() );
		}
		catch(SQLException e)
		{
			ErrorCode = 15;
			if( IsError("GetDateTime() " + e) ) return value;
		}
		catch(ParseException ee)
		{
			ErrorCode = 15;
			if( IsError("GetDateTime() " + ee) ) return value;
		}
		
		return value;
	}

	public int GetRecordCount()
	{
		int value = 0;
		if( IsError("GetRecordCount()") ) return value;
		
		try
		{
			int now = rs.getRow();
			rs.last();
			value = rs.getRow();
			rs.absolute(now);
		}
		catch(SQLException e)
		{
			ErrorCode = 9;
			if( IsError("GetRecordCount() " + e) ) return value;
		}
		
		return value;
	}
	public int GetColumnCount()
	{
		int value = 0;
		if( IsError("GetColumnCount()") ) return value;
		
		try
		{
			value = rs.getMetaData().getColumnCount();
		}
		catch(SQLException e)
		{
			ErrorCode = 10;
			if( IsError("GetColumnCount() " + e) ) return value;
		}
		
		return value;
	}
	public String GetColumnName(int index)
	{
		String value = "";
		if( IsError("GetColumnName()") ) return value;
		
		try
		{
			value = rs.getMetaData().getColumnName(index + 1);
		}
		catch(SQLException e)
		{
			ErrorCode = 11;
			if( IsError("GetColumnName() " + e) ) return value;
		}
		
		return value;
	}
		
	public void SetWhere(String _where)
	{
		where = _where;
	}
	
	public void MoveNext()
	{
		eof = true;
		
		if( IsError("MoveNext()") ) return;
		
		try
		{
			eof = !rs.next();
		}
		catch(SQLException e)
		{
			ErrorCode = 16;
			if( IsError("MoveNext() " + e) ) return;
		}
	}
}

public class mCDatabase extends mCDatabase_base 
{
	Connection conn = null;
	
	public mCDatabase(HttpServletRequest _request, HttpServletResponse _response)
	{
		request = _request;
		response = _response;
		try
		{
			out = response.getWriter();
		}
		catch(IOException e)
		{
		}
	}
	
	// 打开数据库
	// Open database
	public void OpenDb(JSONObject option)
	{				
		dbtype = option.getString("dbtype");

		try
		{
			Class.forName( option.getString("dbdriver") );
		}
		catch(ClassNotFoundException e)
		{
			ErrorCode = 17;
			if( IsError("OpenDb() " + e) ) return;
		}
		
		switch(dbtype)
		{
			case "mysql":
			{
				try
				{
					String url = "jdbc:mysql://";
					url += option.getString("dblocation") + ":" + option.getString("dbport") + "/";
					url += option.getString("dbname") + "?user=" + option.getString("uid") + "&password=" + option.getString("pwd");
					conn = DriverManager.getConnection(url);
					stmt = conn.createStatement();
				}
				catch(SQLException e)
				{
					ErrorCode = 1;
					if( IsError("OpenDb() " + e) ) return;
				}
			}
			break;
			
			case "sqlserver":
			{
				try
				{
					String url = "jdbc:sqlserver://";
					url += option.getString("dblocation") + ":";
					url += option.getString("dbport") + ";DatabaseName=";
					url += option.getString("dbname");
					conn = DriverManager.getConnection( url, option.getString("uid"), option.getString("pwd") );
					stmt = conn.createStatement();
				}
				catch(SQLException e)
				{
					ErrorCode = 1;
					if( IsError("OpenDb() " + e) ) return;
				}
			}
			break;
		}
	}

	// 关闭数据库
	// Close database
	public void CloseDb()
	{
		if( IsError("CloseDb()") ) return;
		
		try
		{
			stmt.close();
			conn.close();
		}
		catch(SQLException e)
		{
			ErrorCode = 2;
			if( IsError("CloseDb() " + e) ) return;
		}
	}
	
	// 打开记录集
	// Open recordset
	public CRs OpenRs()
	{
		CRs rs = new CRs(request, response, out, ErrorCode, dbtype, stmt, bLog, sLogPath);
		
		if( IsError("OpenRs()") ) return rs;

		return rs;
	}

	// 关闭记录集
	// Close recordset
	public void CloseRs(CRs rs)
	{
		if( IsError("CloseRs()") ) return;

		try
		{
			if(rs.rs != null)
			{
				rs.rs.close();
			}
		}
		catch(SQLException e)
		{
			ErrorCode = 4;
			if( IsError("CloseRs() " + e) ) return;
		}
	}
}
%>
