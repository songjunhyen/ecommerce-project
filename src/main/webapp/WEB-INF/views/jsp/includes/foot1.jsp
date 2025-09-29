<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
  /* --- Footer 기본 --- */
  #siteFooter { background:#111; color:#ddd; }
  #siteFooter .inner { max-width:1200px; margin:0 auto; padding:28px 16px; }
  #siteFooter .links { display:flex; flex-wrap:wrap; gap:12px 18px; margin-bottom:10px; }
  #siteFooter a { color:#ddd; text-decoration:none; }
  #siteFooter a:hover { color:#fff; text-decoration:underline; }
  #siteFooter .copy { color:#aaa; font-size:12px; }

  /* --- Sticky Layout (body에 layout-sticky 클래스가 있을 때만) --- */
  body.layout-sticky { min-height:100dvh; display:flex; flex-direction:column; margin:0; }
  body.layout-sticky > #siteHeader { flex:0 0 auto; }
  body.layout-sticky > main { flex:1 0 auto; }
  body.layout-sticky > #siteFooter { flex:0 0 auto; margin-top:auto; }
</style>

<footer id="siteFooter">
  <div class="inner">
    <div class="links">
      <a href="#">소개</a><span>|</span>
      <a href="#">개인정보 처리 방침</a><span>|</span>
      <a href="#">이용약관</a><span>|</span>
      <a href="#">입점/제휴 문의</a><span>|</span>
      <a href="#">고객지원</a>
    </div>
    <div class="copy">© 2025 E-커머스 프로젝트 · 고객센터 02-0000-0000</div>
  </div>
</footer>
