<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<div id="logoutModal"
     style="
        display:none;
        position:fixed;
        inset:0;
        background:rgba(15,23,42,0.48);
        backdrop-filter:blur(4px);
        -webkit-backdrop-filter:blur(4px);
        align-items:center;
        justify-content:center;
        z-index:9999;
     ">

    <div style="
        width:440px;
        max-width:calc(100% - 32px);
        background:#FFFFFF;
        border-radius:16px;
        box-shadow:0 20px 50px rgba(15,23,42,0.22);
        overflow:hidden;
        text-align:center;
    ">

        <div style="
            padding:22px 24px 8px;
        ">

            <div style="
                width:60px;
                height:60px;
                margin:0 auto 14px;
                border-radius:16px;
                background:#FEF2F2;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#EF4444;
            ">

                <svg viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round"
                     width="28"
                     height="28">

                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>

                </svg>

            </div>

            <h3 style="
                margin:0 0 6px;
                font-size:20px;
                font-weight:700;
                color:#1E293B;
            ">
                Logout
            </h3>

            <p style="
                margin:0 0 20px;
                font-size:16px;
                color:#475569;
            ">
                Are you sure you want to logout?
            </p>

        </div>

        <div style="
            display:flex;
            gap:10px;
            padding:0 0 0;
            border-top:1px solid #E2E8F0;
        ">

            <button type="button"
                    onclick="closeLogoutModal()"
                    style="
                        flex:1;
                        height:44px;
                        border:1px solid #E2E8F0;
                        border-radius:8px;
                        background:#FFFFFF;
                        color:#334155;
                        font-size:14px;
                        font-weight:600;
                        cursor:pointer;
                    ">
                Cancel
            </button>

            <button type="button"
                    onclick="confirmLogout()"
                    style="
                        flex:1;
                        height:44px;
                        border:none;
                        border-radius:8px;
                        background:#EF4444;
                        color:#FFFFFF;
                        font-size:14px;
                        font-weight:600;
                        cursor:pointer;
                    ">
                Logout
            </button>

        </div>

    </div>

</div>

<script>
    function openLogoutModal() {
        var modal = document.getElementById("logoutModal");
        if (modal) {
            modal.style.display = "flex";
        }
    }

    function closeLogoutModal() {
        var modal = document.getElementById("logoutModal");
        if (modal) {
            modal.style.display = "none";
        }
    }

    function confirmLogout() {
        window.location.href = "<%= request.getContextPath() %>/logout";
    }

    window.addEventListener("click", function(event) {
        var modal = document.getElementById("logoutModal");

        if (event.target === modal) {
            closeLogoutModal();
        }
    });
</script>
