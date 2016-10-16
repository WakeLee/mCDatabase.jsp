<%@ page import="java.io.File" %> 
<%@ page import="java.io.FileInputStream" %> 
<%@ page import="java.io.FileNotFoundException" %> 
<%@ page import="java.util.Scanner" %> 
<%@ page import="java.util.Date" %> 
<%@ page import="java.text.SimpleDateFormat" %>

<%!
JSONObject filetojson(String file)
{
	StringBuffer buffer = new StringBuffer();
	
	try
	{		
		File f = new File(this.getServletContext().getRealPath("/") + file);
		Scanner scan = new Scanner( new FileInputStream(f) );
		while( scan.hasNext() )
		{
			buffer.append( scan.next() );
		}
		scan.close();
	}
	catch(FileNotFoundException e)
	{
	}
	
	return JSONObject.fromObject( buffer.toString() );
}
%>
