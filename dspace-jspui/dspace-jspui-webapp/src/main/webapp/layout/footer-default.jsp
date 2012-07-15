<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
    String rightbar = (String) request.getAttribute("dspace.layout.rightbar");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    String uri = (String) request.getRequestURI();
%>
<%-- End of page content --%>
</div>
</div>
<% if (!(navbar.indexOf("admin") > -1)) {%>
<div class="divrightbar">
    <div class="divmargin">
        <%-- Right-hand side bar if appropriate --%>
        <%
            if (uri.indexOf("/home.jsp", 0) == -1) {
        %>

        <dspace:include page="/layout/navigation-default.jsp" />

        <%                        }
        %>
        <%
            if (sidebar != null) {
        %>

        <%= sidebar%>

        <%
            }
        %>
        <%
            if (rightbar != null) {
        %>

        <dspace:include page="<%= rightbar%>" />

        <%
            }
        %>
    </div>
</div>
<%}%>
<div style="clear: both"></div>
<div  style="display:none;">
    <div id="div_preview">
    </div>
    <div id="div_download">
        <div class="formcode">
            <div>
                <form method="get" action="">
                    <span class="title_formcode">Nhập mã Download</span>
                    <input type="text" class="input_formcode"/>
                    <input type="submit" value="Nhập" class="submit_formcode"/>
                </form>
            </div>
            <div>
                <span class="thongbao">ĐỂ NHẬN MÃ DOWNLOAD, MỜI BẠN SOẠN TIN THEO CÚ PHÁP </span>
                <span class="tukhoa">IPC IT </span>
                <span class="thongbao">gửi</span> 
                <span class="dauso">
                    8517
                    <span class="phitn">(5000 đ/1 tin nhắn)</span>
                </span>
            </div>
        </div>
    </div>
</div>
</div>
<div class="divfooter">
    <%-- Page footer --%>
    <div class="div_box_footer">
        <div class="div_box_footer_intro">
            <p class="footer_title">TẬP ĐOÀN BƯU CHÍNH VIỄN THÔNG VIỆT NAM</p>
            <p>Giấy phép 6xx/GP - INTER BVHTT - Quản lý phát triển: Nguyễn Tuấn Anh</p>
            <p>Đơn vị thực hiện: Trung tâm Thông tin và Quan hệ công chúng - 57 Huỳnh Thúc Kháng - Hà Nội</p>
            <p>Mọi thắc mắc xin liên hệ quản trị website: Nguyễn Tuấn Mạnh - 0915 038 868 - Email: <a href="mailto: manhnt@vnpt.vn" style="color: #666">manhnt@vnpt.vn</a></p>
        </div>
        <div class="div_box_counter">
            <script  >
                var url = window.location.href;
                if(url.charAt(url.length-1) == "/"){
                    unSelected();	 
                    jQuery('.nav-home').parent().attr("class", "current"); 
                }
                if (url.indexOf("category")>-1) {	
                    unSelected();	 
                    jQuery('.nav-community-list').parent().attr("class", "current"); 
                }	 
                if (url.indexOf('dateissued')>-1) {
                    unSelected();
                    jQuery('.nav-dateissued').parent().attr("class", "current"); 
                }
                if (url.indexOf('author')>-1) {
                    unSelected();
                    jQuery('.nav-author').parent().attr("class", "current"); 
                }
                if (url.indexOf('title')>-1) {
                    unSelected();
                    jQuery('.nav-title').parent().attr("class", "current"); 
                }
                if (url.indexOf('subject')>-1) {
                    unSelected();
                    jQuery('.nav-subject').parent().attr("class", "current"); 
                }
                if (url.indexOf('dspace-admin')>-1 || url.indexOf('tools')>-1 || url.indexOf('statistics')>-1) { 
                    unSelected();
                    jQuery('.nav-dspace-admin').parent().attr("class", "current"); 
                }
                function unSelected(){
                    jQuery('#navid li').attr("class", "");
                }
                // config window
                if(jQuery(window).height() - 250 > 600)
                    jQuery('.divcontent').css('min-height', jQuery(window).height() - 250+"px");
                //                            if(jQuery('.divnavbar').html() == null)
                //                            {
                //                                jQuery('.divpagecontent').css('width', jQuery(window).width() - 416+"px");
                //                            }else{
                //                                jQuery('.divpagecontent').css('width', jQuery(window).width() - 291+"px");
                //                            }
            </script>
            <!-- Histats.com  START  (standard)-->
            <script >
                document.write(unescape("%3Cscript src=%27http://s10.histats.com/js15.js%27 type=%27text/javascript%27%3E%3C/script%3E"));</script>
            <a href="http://www.histats.com" target="_blank" title="site stats" >
                <script   >
                    try {Histats.start(1,1884414,4,407,118,80,"00011011");
                        Histats.track_hits();} catch(err){};
                </script>
            </a>
            <noscript><a href="http://www.histats.com" target="_blank"><img  src="http://sstatic1.histats.com/0.gif?1884414&101" alt="site stats"></a></noscript>
            <!-- Histats.com  END  -->
        </div>
    </div>
</div>
</div>
</body>
</html>