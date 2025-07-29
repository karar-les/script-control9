--[[
🔥 سكريبت محمد الشمري مع نظام التحديث التلقائي 🔥
--]]

-- متغيرات النظام
local savedValues = {}
local startTime = os.time()
local PASSWORD = "TUX3T"
local fancyMessages = {
    "محمد الشمري يرحب بكم",
}
local ONLINE_CHECK_URL = "https://raw.githubusercontent.com/karar-les/script-control9/refs/heads/main/expiry.txt"
local SCRIPT_STATUS_URL = "https://raw.githubusercontent.com/karar-les/script-control9/refs/heads/main/status.txt"
local UPDATE_URL = "https://raw.githubusercontent.com/karar-les/script-control9/refs/heads/main/script.lua"
local VERSION_URL = "https://raw.githubusercontent.com/karar-les/script-control9/refs/heads/main/version.txt"
local CURRENT_VERSION = "1.0" -- قم بتغيير هذا عند كل تحديث

-- دالة استعادة القيم الأصلية
function restoreOriginalValues()
    if #savedValues > 0 then
        gg.setValues(savedValues)
        gg.toast("تم استعادة القيم الأصلية")
    end
    gg.setSpeed(1.0) -- إعادة سرعة اللعبة إلى وضعها الطبيعي
end

-- دالة إيقاف السكربت
function stopScript(reason)
    restoreOriginalValues()
    gg.alert(reason .. "\n\nللتواصل: @vip6t6")
    os.exit()
end

-- دالة التحقق من حالة السكربت على السيرفر
function checkScriptStatus()
    local success, result = pcall(gg.makeRequest, SCRIPT_STATUS_URL)
    if not success or not result or not result.content then
        return "error"
    end
    
    local status = result.content:lower():match("%a+")
    return status or "online"
end

-- دالة جلب تاريخ الانتهاء من السيرفر
function getOnlineExpiry()
    local status = checkScriptStatus()
    if status == "offline" then
        stopScript("⚠️ تم إيقاف السكربت أونلاين من قبل المطور")
    elseif status == "error" then
        stopScript("⚠️ تعذر التحقق من حالة السكربت!")
    end
    
    local success, result = pcall(gg.makeRequest, ONLINE_CHECK_URL)
    if not success or not result or not result.content then
        stopScript("⚠️ تعذر الاتصال بالسيرفر!")
    end
    
    local expiryTime = tonumber(result.content:match("%d+"))
    if not expiryTime then
        stopScript("⚠️ خطأ في تنسيق التاريخ بالسيرفر!")
    end
    
    return expiryTime
end

-- دالة التحقق الدوري من حالة السكربت
function checkOnlineStatus()
    local status = checkScriptStatus()
    if status == "offline" then
        stopScript("⚠️ تم إيقاف السكربت أونلاين من قبل المطور")
    end
end

-- دالة حساب الوقت المتبقي
function getRemainingTime()
    local expiryTime = getOnlineExpiry()
    local now = os.time()
    local remaining = expiryTime - now
    
    if remaining <= 0 then
        return "✖︎ انتهت الصلاحية (السيرفر)"
    end
    
    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    
    return string.format("⏳ المتبقي: %d يوم، %d ساعة، %d دقيقة", days, hours, minutes)
end

-- دالة التحقق من التحديثات
function checkForUpdates()
    local success, result = pcall(gg.makeRequest, VERSION_URL)
    if not success or not result or not result.content then
        return false, "تعذر الاتصال بالسيرفر للتحقق من التحديثات"
    end
    
    local latestVersion = result.content:match("%d+.%d+")
    if not latestVersion then
        return false, "خطأ في تنسيق رقم الإصدار"
    end
    
    if latestVersion > CURRENT_VERSION then
        return true, "يتوفر تحديث جديد (الإصدار "..latestVersion..")"
    end
    
    return false, "أنت تستخدم أحدث إصدار ("..CURRENT_VERSION..")"
end

-- دالة التحديث التلقائي
function performUpdate()
    local hasUpdate, message = checkForUpdates()
    if not hasUpdate then
        gg.alert(message)
        return
    end
    
    local choice = gg.alert(message.."\n\nهل تريد التحديث الآن؟", "نعم", "لا")
    if choice ~= 1 then return end
    
    local success, result = pcall(gg.makeRequest, UPDATE_URL)
    if not success or not result or not result.content then
        gg.alert("فشل في تحميل السكربت المحدث")
        return
    end
    
    local filePath = gg.EXT_STORAGE.."/Download/script_update.lua"
    local file = io.open(filePath, "w")
    if not file then
        gg.alert("فشل في إنشاء ملف التحديث")
        return
    end
    
    file:write(result.content)
    file:close()
    
    gg.alert("تم تنزيل التحديث بنجاح!\nسيتم إعادة تشغيل السكربت الآن")
    gg.loadFile(filePath)
end

-- دالة عرض معلومات المطور
function showInfo()
    checkOnlineStatus()
    
    local info = [[
📌 معلومات المطور:

✯ الاسم: محمد الشمري
✯ تيليجرام: @vip6t6
✯ قناة التليجرام: @TUX3T

]] .. getRemainingTime() .. "\n\nالإصدار الحالي: " .. CURRENT_VERSION

    gg.alert(info)
end

-- التحقق من الصلاحية
function checkAuth()
    gg.alert("☛ محمد الشمري ☚\n\nتلكرام الدعم: @vip6t6")
    
    checkOnlineStatus()
    
    local input = gg.prompt({"🔐 أدخل الباسورد:"}, nil, {"text"})
    if not input or input[1] ~= PASSWORD then
        stopScript("✖︎ كلمة المرور خاطئة!")
    end

    local expiryTime = getOnlineExpiry()
    local now = os.time()
    
    if now > expiryTime then
        stopScript("✖︎ انتهت صلاحية السكربت!")
    elseif (expiryTime - now) < 86400 then
        gg.alert("⚠️ صلاحية السكربت تنتهي خلال 24 ساعة!")
    end

    -- التحقق من التحديثات عند التشغيل
    local hasUpdate, updateMsg = checkForUpdates()
    if hasUpdate then
        gg.alert(updateMsg)
    end

    gg.alert("✔︎ تم التحقق بنجاح!\n\nاستمتع بالسكربت!")
end

-- وظيفة التحقق من وقت التشغيل
function checkRuntime()
    if os.time() - startTime > 120 then
        checkOnlineStatus()
        startTime = os.time()
    end
end

-- تفعيل منظر iPad
function iPadView()
    checkOnlineStatus()
    
    gg.setRanges(gg.REGION_C_DATA)
    gg.searchNumber("0.3~03.99", gg.TYPE_DOUBLE)
    gg.searchNumber("0.3~03.99", gg.TYPE_DOUBLE)
    gg.refineNumber("0.3~03.99", gg.TYPE_DOUBLE)
    local revert = gg.getResults(10)

    if #revert == 0 then
        gg.alert("هناك خطا ما ✖︎")
        return
    end

    gg.editAll("2", gg.TYPE_DOUBLE)
    gg.toast("منضور الايباد يعمل الان ✔︎")
end

-- تفعيل الاستحواذ
function activatePossession()
    checkOnlineStatus()
    
    gg.clearResults()
    gg.setRanges(gg.REGION_C_DATA)
    gg.searchNumber("1065353216;720;486;30000;1001:17", gg.TYPE_FLOAT)
    gg.searchNumber("1065353216;720;486;30000;1001:17", gg.TYPE_DWORD)
    gg.refineNumber("1065353216", gg.TYPE_DWORD)
    local results = gg.getResults(10)
    savedValues = {}
    for i, v in ipairs(results) do
        savedValues[i] = {address = v.address, flags = gg.TYPE_DWORD, value = v.value}
    end
    gg.editAll("1063199999", gg.TYPE_DWORD)
    gg.toast("تم تفعيل الاستحواذ ✔︎")
end

-- تفعيل الهدف الخارق
function superGoal()
    checkOnlineStatus()
    
    gg.searchNumber("1;194.2548828125;50757.265625;13257032.0", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
    gg.refineNumber("0.87165826559", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
    revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
    gg.editAll("1.1", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.toast("تم تفعيل الهدف الخارق بنجاح! ✔︎")
end

-- إلغاء المباراة الوضع البطيئ
function cancelMatchSlow()
    checkOnlineStatus()
    
    gg.setSpeed(0.25)
    gg.toast("تم الغاء المباراه (الوضع البطيئ) ✔︎!")
end

-- إلغاء المباراة الوضع السريع مع تفعيل الاستحواذ
function cancelMatchFast()
    checkOnlineStatus()
    
    -- تفعيل الاستحواذ أولاً
    activatePossession()
    
    -- إلغاء المباراة مع الحفاظ على السرعة الطبيعية
    gg.setSpeed(1.0)
    gg.toast("تم الغاء المباراه (الوضع السريع) ✔︎!")
end

-- إعادة ضبط جميع القيم
function resetAll()
    checkOnlineStatus()
    
    restoreOriginalValues()
    gg.toast("🔄 تم إعادة ضبط جميع القيم إلى الأصل")
end

-- قائمة السرعة
function speedMenu()
    while true do
        checkOnlineStatus()
        
        local choice = gg.choice({
            "⏲︎ تسريع الوقت x2",
            "⏲︎ تسريع الوقت x3",
            "⏲︎ تسريع الوقت x5",
            "⏲︎ تسريع الوقت x10",
            "⏲︎ إيقاف تسريع الوقت",
            "🔙 رجوع"
        }, nil, "☰ قائمة السرعة")
        
        if choice == 1 then
            gg.setSpeed(2.0)
            gg.toast("⏲︎ تم تفعيل السرعة ×2")
        elseif choice == 2 then
            gg.setSpeed(3.0)
            gg.toast("⏲︎ تم تفعيل السرعة ×3")
        elseif choice == 3 then
            gg.setSpeed(5.0)
            gg.toast("⏲︎ تم تفعيل السرعة ×5")
        elseif choice == 4 then
            gg.setSpeed(10.0)
            gg.toast("⏲︎ تم تفعيل السرعة ×10")
        elseif choice == 5 then
            gg.setSpeed(1.0)
            gg.toast("⏲︎ تم إيقاف التسريع")
        else
            break
        end
    end
end

-- قائمة البكجات
function packsMenu()
    while true do
        checkOnlineStatus()
        
        local choice = gg.choice({
            "®︎ بكج بيليه",
            "✯ بكج بلتز كير",
            "✯ بكج نجوم الأسبوع",
            "♛ جميع البكجات",
            "🔙 رجوع"
        }, nil, "☰ قائمة البكجات")
        
        if choice == 1 then
            gg.toast("®︎ تم فتح بكج بيليه")
        elseif choice == 2 then
            gg.toast("✯ تم فتح بكج بلتز كير")
        elseif choice == 3 then
            gg.toast("✯ تم فتح بكج نجوم الأسبوع")
        elseif choice == 4 then
            gg.toast("♛ تم فتح جميع البكجات")
        else
            break
        end
    end
end

-- القائمة الرئيسية
function mainMenu()
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            checkRuntime()
            
            local menu = gg.choice({
                "☰ قائمة المباراة",
                "☰ قائمة السرعة",
                "☰ قائمة البكجات",
                "🔄 التحقق من التحديثات",
                "📌 معلومات المطور",
                "🔄 إعادة ضبط القيم",
                "✖︎ خروج"
            }, nil, "احذر التقليد تلكرام @TUX3T")
            
            if menu == 1 then
                local matchChoice = gg.choice({
                    "®︎ تفعيل الاستحواذ",
                    "®︎ تفعيل منضور الايباد",
                    "®︎ تفعيل الهدف الخارق",
                    "®︎ إلغاء المباراة (الوضع البطيئ)",
                    "®︎ إلغاء المباراة (الوضع السريع)",
                    "🔙 رجوع"
                }, nil, "☰ قائمة المباراة")
                
                if matchChoice == 1 then
                    activatePossession()
                elseif matchChoice == 2 then
                    iPadView()
                elseif matchChoice == 3 then
                    superGoal()
                elseif matchChoice == 4 then
                    cancelMatchSlow()
                elseif matchChoice == 5 then
                    cancelMatchFast()
                end
                
            elseif menu == 2 then
                speedMenu()
                
            elseif menu == 3 then
                packsMenu()
                
            elseif menu == 4 then
                performUpdate()
                
            elseif menu == 5 then
                showInfo()
                
            elseif menu == 6 then
                resetAll()
                
            elseif menu == 7 then
                restoreOriginalValues()
                gg.toast("اهلا وسهلا ✔︎")
                os.exit()
            end
        end
        gg.sleep(1000)
    end
end

-- بداية التشغيل
checkAuth()
mainMenu()
