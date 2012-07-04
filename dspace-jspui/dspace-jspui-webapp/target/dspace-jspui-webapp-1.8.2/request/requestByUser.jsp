

<%@page import="org.dspace.app.webui.servlet.RequestByUserServlet"%>
<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%-- 
    Document   : requestByUser
    Created on : Mar 29, 2012, 3:21:34 PM
    Author     : Linh
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<!DOCTYPE html>
<dspace:layout titlekey="jsp.community-list.title">
     <form method="post" action="<%=request.getContextPath()%>/requestByUser">
         
            Yêu cầu:
         <br>
         <textarea name="request" rows="20" cols="50" draggable="true"></textarea>
         <br>
             <input type="submit" name="submit" value="Gửi" />
                  
                            </form>
</dspace:layout>