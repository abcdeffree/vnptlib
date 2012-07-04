<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.core.ConfigurationManager"%>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%--
  - Default navigation bar
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>
<div class="div_box_rightbar">
    <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/help.png"/>Hỗ trợ từ quản trị</h3>
    <ul>
        <li>
            <p style="width: 268px;height: 100px">
            <a href="ymsgr:SendIM?le_huy_thuc">
                <img alt="'Yahoo!" border="0" src="http://opi.yahoo.com/online?u=le_huy_thuc&amp;m=g&amp;t=14&amp;l=us&amp;opi.jpg" style="width: 112px; height: 89px;">
            </a>
            <a href="ymsgr:SendIM?le_huy_thuc">
                <img alt="'Yahoo!" border="0" src="http://opi.yahoo.com/online?u=le_huy_thuc&amp;m=g&amp;t=14&amp;l=us&amp;opi.jpg" style="width: 112px; height: 89px;">
            </a>
            </p>
        </li>
        <li>
            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, 
                    
                \"help.index\")%>"><img src="<%= request.getContextPath()%>/image/soft/help.png" /><fmt:message key="jsp.layout.navbar-default.help"/></dspace:popup>
                          <p>Hướng dẫn cách sử dụng thư viện</p>
            </li>
            <li>
                <a target="_blank" href="<%= request.getContextPath()%>/feedback">
                <img src="<%= request.getContextPath()%>/image/soft/email_to_friend.png">GỬI YÊU CẦU
            </a>
            <p>Gửi yêu cầu cho người quản trị</p>
        </li>
    </ul>
</div>
<div class="div_box_rightbar">
    <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/soft_help.png"/>Các phần mềm hỗ trợ</h3>
    <ul>
        <li><a href="<%= request.getContextPath()%>/resources/unikey40RC2-1101-win32.zip"><img alt="" src="<%= request.getContextPath()%>/image/soft/unikey.png">UniKey</a><p>Bộ gõ Tiếng Việt miễn phí</p></li>
        <li><a href="<%= request.getContextPath()%>/resources/abc-vni-font.zip"><img alt="" src="<%= request.getContextPath()%>/image/soft/font.png">Font ABC-VNI</a><p>Bộ Font ABC - VNI thông dụng</p></li>	
        <li><a href="<%= request.getContextPath()%>/resources/WinRAR.v3.91.Incl.Keyfilemaker-CORE.zip"><img alt="" src="<%= request.getContextPath()%>/image/soft/WinRAR.png">WinRAR</a><p>Soft nén và giải nén mạnh</p></li>
        <li><a href="<%= request.getContextPath()%>/resources/flashget-en.exe"><img alt="" src="<%= request.getContextPath()%>/image/soft/flashget.png">Flashget v3.3</a><p>Trình hỗ trợ tăng tốc download files</p></li>
        <li><a target="blank" href="http://www.mozilla.org/vi/firefox/new/"><img alt="" src="<%= request.getContextPath()%>/image/soft/firefox.png">Mozilla Firefox</a><p>Trình duyệt Web nhanh nhất</p></li>
        <li><a href="http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/win/5.x/5.1/enu/FoxitReader510.1021_enu_Setup.exe"><img alt="" src="<%= request.getContextPath()%>/image/soft/foxitreader.png">Foxit Reader 5</a><p>Xem PDF miễn phí</p></li>														
    </ul>
</div>
<%
    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    if (feedEnabled) {
%>
<div class="div_box_rightbar">
    <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/soft_help.png"/><fmt:message key="jsp.home.feeds"/></h3>
    
        <%
            String feedData = "ALL:" + ConfigurationManager.getProperty("webui.feed.formats");
            String[] fmts = feedData.substring(feedData.indexOf(':') + 1).split(",");
            String icon = null;
            int width = 0;
            for (int j = 0; j < fmts.length; j++) {
                if ("rss_1.0".equals(fmts[j])) {
                    icon = "rss1.gif";
                    width = 80;
                } else if ("rss_2.0".equals(fmts[j])) {
                    icon = "rss2.gif";
                    width = 80;
                } else {
                    icon = "rss.gif";
                    width = 36;
                }
        %>
        <a href="<%= request.getContextPath()%>/feed/<%= fmts[j]%>/site"><img src="<%= request.getContextPath()%>/image/<%= icon%>" alt="RSS Feed" width="<%= width%>" height="15" vspace="3" /></a>
            <%
                }
            %>
    
</div>
<%
    }
%>