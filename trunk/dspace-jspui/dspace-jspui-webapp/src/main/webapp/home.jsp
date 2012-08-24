<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.content.Collection"%>
<%@page import="org.dspace.content.DCDate"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.dspace.content.DCValue"%>
<%@page import="org.dspace.content.Item"%>
<%@page import="org.dspace.app.webui.components.RecentSubmissions"%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>

<%
    Community[] communities = (Community[]) request.getAttribute("communities");

    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    String topNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));
    String adventiseNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-adventise.html"));

    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<dspace:layout locbar="nolink" titlekey="jsp.home.title">
    <div class="home_marquee">
	<marquee behavior="scroll" direction="left" width="620" height="30" 
	scrollamount="2" scrolldelay="20" onmouseover="this.stop()" onmouseout="this.start()">		
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/555">
		<font color="#800000">Radio System Design for Telecommunications</font>
		</a>&nbsp;&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/565">
		<font color="#800000">M-Commerce Crash Cuorse: The Technology and Business of Next Generation Internet Services</font>
		</a>
		&nbsp;		
		&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/566">
		<font color="#800000">How to build a digital library</font>
		</a>
		&nbsp;
		&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/567">
		<font color="#800000">IT Project +: Study Guide</font>
		</a>
		&nbsp;
		&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/559">
		<font color="#800000">Statistical and Adaptive Signal Processing: Spectral Estimation, Signal Modeling, Adaptive Filtering and Array Processing</font>
		</a>
		&nbsp;
		&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/560">
		<font color="#800000">ATM for Public Networks</font>
		</a>&nbsp;
		&nbsp;
		<a class="menu_sub2" href="/dspace/handle/123456789/562">
		<font color="#800000">Satellite-Based Cellular Communications</font>
		</a>&nbsp;
		&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/564">
		<font color="#800000">M-Commerce Crash Course: The Technology and Business of Next Generation Internet Services</font>
		</a>&nbsp;&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/555">
		<font color="#800000">Radio System Design for Telecommunications</font>
		</a>&nbsp;&nbsp;
		<img src="http://113.160.32.22/dspace/image/document.png" height="18">
		<a class="menu_sub2" href="/dspace/handle/123456789/550">
		<font color="#800000">Advanced Digital Signal Processing and Noise Reduction</font>
		</a>
		</marquee>
        </div>
    <div class="div_top_new">
        <%= sideNews%>
    </div>
    <div class="div_toppage_content">
        <%
            if (communities.length != 0) {
                int num_row = (int) communities.length / 2;
        %>
        <div class="div_list_community">
            <ul class="ul_community">
                <%

                    for (int i = 0; i < num_row; i++) {%>  
                <li class="li_community">
                    <a href="<%= request.getContextPath()%>/handle/<%= communities[i].getHandle()%>"><%= communities[i].getMetadata("name")%></a>
                    <%
                        if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
                    %>
                    <!--<span class="count">[<%//= ic.getCount(communities[i])%>]</span> -->
                    <%                        }

                    %>
                <li>
                    <%
                        }
                    %>
            </ul>
        </div>
        <div class="div_list_community">
            <ul class="ul_community">
                <%

                    for (int i = num_row; i < communities.length; i++) {%>  
                <li class="li_community">
                    <a href="<%= request.getContextPath()%>/handle/<%= communities[i].getHandle()%>"><%= communities[i].getMetadata("name")%></a>
                    <%
                        if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
                    %>
                    <!--span class="count">[<%//= ic.getCount(communities[i])%>]</span-->
                    <%                        }

                    %>
                <li>
                    <%
                        }
                    %>
            </ul>
        </div>
        <%
            }
        %>
    </div>
    <div class="div_vnpt_event">
        <img src="<%= request.getContextPath()%>/image/QCMobifone.jpg" width="230"/>
    </div>
    <div class="clearall"></div>
    <div class="div_top_new">
        <%= topNews%>
    </div>
    <div class="clearall"></div>
    <%-- Recently Submitted items --%>
    <div class="div_home_content">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_new.png"/><fmt:message key="jsp.community-home.recentsub"/><a href="<%= request.getContextPath()%>/browse?type=dateaccessioned" class="a_recentItem_more">Xem thêm<img  class="image_recentitem_more" src="./image/transparent.gif"/></a></h3>
                <%
                    RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");
                    if (rs != null) {
                        Item[] items = rs.getRecentSubmissions();
                        for (int i = 0; i < items.length; i++) {
                            DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
                            String displayTitle = "Không có tiêu đề";
                            if (dcv != null) {
                                if (dcv.length > 0) {
                                    displayTitle = dcv[0].value;
                                }
                            }
                            DCValue[] dcdes = items[i].getMetadata("dc", "description", null, Item.ANY);
                            String description = "";
                            String full_description = "";
                            if (dcdes != null) {
                                if (dcdes.length > 0) {
                                    description = dcdes[0].value;
                                    full_description = description;
                                    if (description.length() > 200) {
                                        description = description.substring(0, 200) + "&nbsp;&nbsp;<a class='detail_description' rel='"+i+"' href=''>Chi tiết</a>";
                                    }
                                }
                            } 
                            if("".equalsIgnoreCase(description)){
                                dcdes = items[i].getMetadata("dc", "description", "abstract", Item.ANY);
                                if (dcdes != null) {
                                    if (dcdes.length > 0) {
                                        description = dcdes[0].value;
                                        full_description = description;
                                        if (description.length() > 200) {
                                            description = description.substring(0, 200) + "&nbsp;&nbsp;<a class='detail_description' rel='"+i+"' href=''>Chi tiết</a>";
                                        }
                                    }
                                } 
                            }

                            DCValue[] dateissued = items[i].getMetadata("dc", "date", "issued", Item.ANY);
                            String dateissuedval = "";
                            if (dateissued != null) {
                                if (dateissued.length > 0) {
                                    dateissuedval = dateissued[0].value;
                                    //                        DCDate dateissuedvaldate = new DCDate(dateissuedval);
                                    //                        dateissuedval = UIUtil.displayDate(dateissuedvaldate, true, true, (HttpServletRequest)pageContext.getRequest());
                                }
                            }
                            DCValue[] dcauthor = items[i].getMetadata("dc", "contributor", "author", Item.ANY);
                            String authorval = "";
                            if (dcauthor != null) {
                                if (dcauthor.length > 0) {
                                    authorval = dcauthor[0].value;
                                }
                            }
                            DCDate dateaccesionval = new DCDate(items[i].getLastModified());
                            Collection[] collections = items[i].getCollections();
                %>
        <div class="div_recent_item">
            <p class="recentItem">
                <img  class="a_recentitem" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                <a class="a_item_title" href="<%= request.getContextPath()%>/handle/<%= items[i].getHandle()%>"><%= displayTitle%></a>
                <span class="span_date_right"><dspace:date date="<%= dateaccesionval%>" /></span>
            </p>
            <p class="dc_description_<%=i%>">
                <%=description%>
            </p>
            <p class="dc_description_hide dc_description_hide_<%=i%>">
                <%=full_description%>
            </p>
            <p class='info_preview'>
                <%  for (int j = 0; j < collections.length; j++) {%>
                <a href="<%= request.getContextPath()%>/handle/<%= collections[j].getHandle()%>"><%= collections[j].getMetadata("name")%></a>
                <%  }%>
                <% if (!"".equals(authorval)) {%>
                &nbsp;-&nbsp;Tác giả: <span><%=authorval%></span>
                <%}%>
                <% if (!"".equals(dateissuedval)) {%>
                &nbsp;-&nbsp;Xuất bản: <span><%=dateissuedval%></span>
                <%}%>
            </p>
        </div>
        <%
                }
            }
        %>
        <div class="div_box_subbar_content_footer"></div>
    </div>
    <div class="div_box_rightbar">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_good.png"/>Tài liệu nhiều người dùng </h3>
            <%
                RecentSubmissions rsdateissued = (RecentSubmissions) request.getAttribute("recently.submitted.dateissued");
                if (rsdateissued != null) {
                    Item[] items = rsdateissued.getRecentSubmissions();
                    for (int i = 0; i < items.length; i++) {
                        DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
                        String displayTitle = "Untitled";
                        if (dcv != null) {
                            if (dcv.length > 0) {
                                displayTitle = dcv[0].value;
                            }
                        }
            %>
            <p class="recentItem">
            <img  class="a_recentitem_toppage" src="<%= request.getContextPath()%>/image/transparent.gif"/>
            <a href="<%= request.getContextPath()%>/handle/<%= items[i].getHandle()%>"><%= displayTitle%></a></p><%
                    }
                }
            %>
    </div>
    <dspace:sidebar>
        <embed height="349" width="240" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" 
        src="/dspace/image/vnptipcv2.swf" play="true" loop="true" menu="true">
    <div class="div_box_rightbar">
                <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_good.png"/>Liên kết</h3>
                <%= adventiseNews%>
        </div>
    </dspace:sidebar>
</dspace:layout>