-- Универсальное решение для проблемы окрашивания границ предметов
-- в AdiBags при использовании скинов Masque

local addonName, addon = ...
local Masque = LibStub('Masque', true)

-- Настройка для отладки
local DEBUG_MODE = false
local function Debug(...)
    if DEBUG_MODE then
        print("|cff00ffffAdiBags Masque Fixer:|r", ...)
    end
end

----------------------------------------
-- ЧАСТЬ 1: АНАЛИЗ И ПОДГОТОВКА
----------------------------------------

-- Функция для получения всех регионов границы кнопки
local function GetAllBorderRegions(button)
    local regions = {}
    
    -- Стандартная граница AdiBags
    if button.IconQuestTexture then
        table.insert(regions, button.IconQuestTexture)
    end
    
    -- Регионы Masque
    if button.masqueData then
        if button.masqueData.Border then table.insert(regions, button.masqueData.Border) end
        if button.masqueData.IconBorder then table.insert(regions, button.masqueData.IconBorder) end
        if button.masqueData.QuestBorder then table.insert(regions, button.masqueData.QuestBorder) end
    end
    
    return regions
end

-- Функция для проверки, может ли регион быть окрашен через SetVertexColor
local function CanRegionBeColored(region)
    if not region or not region.SetVertexColor then
        return false
    end
    
    -- Попробуем установить и получить цвет
    local originalR, originalG, originalB, originalA = region:GetVertexColor()
    region:SetVertexColor(0.5, 0.5, 0.5, 1)
    local r, g, b, a = region:GetVertexColor()
    
    -- Восстанавливаем оригинальный цвет
    if originalR and originalG and originalB then
        region:SetVertexColor(originalR, originalG, originalB, originalA or 1)
    else
        region:SetVertexColor(1, 1, 1, 1)
    end
    
    -- Проверяем, был ли цвет изменен
    return (r ~= 1 or g ~= 1 or b ~= 1)
end

-- Анализ регионов кнопки для выбора лучшей стратегии
local function AnalyzeButtonRegions(button)
    local strategy = {
        colorableRegions = {},
        preferredRegion = nil,
        needsSpecialHandling = false
    }
    
    -- Получаем все регионы границы
    local regions = GetAllBorderRegions(button)
    
    -- Проверяем каждый регион
    for _, region in ipairs(regions) do
        if CanRegionBeColored(region) then
            table.insert(strategy.colorableRegions, region)
            
            -- Регионы Masque обычно предпочтительнее
            if not strategy.preferredRegion or region ~= button.IconQuestTexture then
                strategy.preferredRegion = region
            end
        end
    end
    
    -- Если нет окрашиваемых регионов, понадобится специальная обработка
    if #strategy.colorableRegions == 0 then
        strategy.needsSpecialHandling = true
    end
    
    -- Сохраняем стратегию в кнопке
    button.__adibags_masque_strategy = strategy
    
    return strategy
end

----------------------------------------
-- ЧАСТЬ 2: МОДИФИКАЦИЯ ОСНОВНЫХ ФУНКЦИЙ
----------------------------------------

-- Модификация функции UpdateBorder в AdiBags
local function ModifyUpdateBorderFunction()
    -- Сохраняем оригинальную функцию
    local origUpdateBorder = buttonProto.UpdateBorder
    
    -- Создаем новую функцию
    function buttonProto:UpdateBorder(isolatedEvent)
        -- Если кнопка не использует Masque, используем стандартное поведение
        if not Masque or not self.masqueData then
            return origUpdateBorder(self, isolatedEvent)
        end
        
        -- Анализируем кнопку при первом вызове
        if not self.__adibags_masque_strategy then
            AnalyzeButtonRegions(self)
        end
        
        local strategy = self.__adibags_masque_strategy
        
        -- Если у нас есть предметы и включена подсветка качества
        if self.hasItem and addon.db.profile.qualityHighlight then
            local _, _, quality = GetItemInfo(self.itemId)
            
            if quality and quality >= ITEM_QUALITY_UNCOMMON then
                local r, g, b = GetItemQualityColor(quality)
                local a = addon.db.profile.qualityOpacity
                
                -- Сохраняем цвет качества
                self.__quality_color = {r, g, b, a}
                
                -- Если у нас есть предпочтительный регион, используем его
                if strategy.preferredRegion then
                    -- Скрываем стандартную границу AdiBags
                    self.IconQuestTexture:Hide()
                    
                    -- Окрашиваем предпочтительный регион
                    strategy.preferredRegion:SetVertexColor(r, g, b, a)
                    if strategy.preferredRegion.Show then
                        strategy.preferredRegion:Show()
                    end
                    
                    -- Отмечаем, что граница окрашена
                    self.__border_colored = true
                    
                    if isolatedEvent then
                        addon:SendMessage('AdiBags_UpdateBorder', self)
                    end
                    return
                    
                -- Если нет предпочтительного региона, но требуется специальная обработка
                elseif strategy.needsSpecialHandling then
                    -- Реализуем специальную стратегию для сложных случаев
                    -- Например, можем изменить настройки существующих регионов
                    
                    -- Для Masque Caith пробуем изменить режим смешивания
                    local border = self.masqueData.Border or self.masqueData.IconBorder or self.masqueData.QuestBorder
                    if border then
                        -- Пробуем различные режимы смешивания
                        border:SetBlendMode("ADD")
                        border:SetVertexColor(r*1.5, g*1.5, b*1.5, a*1.5)
                        border:Show()
                        
                        -- Скрываем стандартную границу AdiBags
                        self.IconQuestTexture:Hide()
                        
                        -- Отмечаем, что граница окрашена
                        self.__border_colored = true
                        
                        if isolatedEvent then
                            addon:SendMessage('AdiBags_UpdateBorder', self)
                        end
                        return
                    end
                end
            end
        end
        
        -- Если мы здесь, значит, особые случаи не сработали
        -- Восстанавливаем оригинальное состояние, если граница была окрашена ранее
        if self.__border_colored then
            -- Восстанавливаем цвета регионов
            for _, region in ipairs(strategy.colorableRegions) do
                region:SetVertexColor(1, 1, 1, 1)
            end
            
            -- Сбрасываем флаг
            self.__border_colored = nil
            self.__quality_color = nil
        end
        
        -- Вызываем оригинальную функцию для стандартного поведения
        return origUpdateBorder(self, isolatedEvent)
    end
end

-- Модификация обработки кнопки для лучшей совместимости с Masque
local function ModifyButtonHandling()
    -- Перехватываем событие обновления всех кнопок
    addon:RegisterMessage("AdiBags_UpdateAllButtons", function()
        -- Проходим по всем контейнерам
        for _, container in pairs(addon.containers or {}) do
            -- Проходим по всем кнопкам
            for _, button in pairs(container.buttons or {}) do
                -- Если кнопка имеет сохраненный цвет качества и была окрашена
                if button.__quality_color and button.__border_colored then
                    -- Получаем стратегию или анализируем кнопку
                    local strategy = button.__adibags_masque_strategy
                    if not strategy then
                        strategy = AnalyzeButtonRegions(button)
                    end
                    
                    -- Применяем цвет ко всем окрашиваемым регионам
                    for _, region in ipairs(strategy.colorableRegions) do
                        region:SetVertexColor(unpack(button.__quality_color))
                    end
                end
            end
        end
    end)
    
    -- Если доступно, регистрируем обработчик событий Masque
    if Masque and Masque.Register then
        Masque.Register(addonName, function()
            -- Вызываем обновление всех кнопок с небольшой задержкой
            C_Timer.After(0.1, function()
                addon:SendMessage('AdiBags_UpdateAllButtons')
            end)
        end)
    end
end

----------------------------------------
-- ЧАСТЬ 3: СПЕЦИАЛЬНЫЕ ХУКИ ДЛЯ MASQUE
----------------------------------------

-- Перехват функции SkinButton в Masque
local function HookMasqueSkinButton()
    if Masque and Masque.Core and Masque.Core.SkinButton then
        -- Оригинальная функция
        local origSkinButton = Masque.Core.SkinButton
        
        -- Создаем хук
        Masque.Core.SkinButton = function(Button, Regions, SkinID, ...)
            -- Вызываем оригинальную функцию
            local result = origSkinButton(Button, Regions, SkinID, ...)
            
            -- Проверяем, принадлежит ли кнопка AdiBags
            if Button.__MSQ_Addon == addonName then
                -- Сбрасываем стратегию, чтобы она была пересчитана
                Button.__adibags_masque_strategy = nil
                
                -- Если у кнопки есть сохраненный цвет качества, применяем его заново
                if Button.__quality_color and Button.__border_colored then
                    -- Анализируем кнопку
                    local strategy = AnalyzeButtonRegions(Button)
                    
                    -- Применяем цвет
                    if strategy.preferredRegion then
                        strategy.preferredRegion:SetVertexColor(unpack(Button.__quality_color))
                    end
                end
            end
            
            return result
        end
    end
end

-- Перехват функций, связанных с обработкой границ в Masque
local function HookMasqueBorderFunctions()
    -- Хук для SkinIconBorder
    if Masque and Masque.Core and Masque.Core.SkinIconBorder then
        local origSkinIconBorder = Masque.Core.SkinIconBorder
        
        Masque.Core.SkinIconBorder = function(Region, Button, Skin, xScale, yScale)
            -- Вызываем оригинальную функцию
            origSkinIconBorder(Region, Button, Skin, xScale, yScale)
            
            -- Проверяем, принадлежит ли кнопка AdiBags
            if Button.__MSQ_Addon == addonName then
                -- Если регион может быть окрашен, модифицируем его для лучшей поддержки цвета
                if CanRegionBeColored(Region) then
                    -- Изменяем режим смешивания для лучшей поддержки цвета
                    local currentBlendMode = Region:GetBlendMode()
                    if currentBlendMode == "BLEND" then
                        Region:SetBlendMode("ADD")
                    end
                end
                
                -- Если у кнопки есть сохраненный цвет качества, применяем его
                if Button.__quality_color and Button.__border_colored then
                    Region:SetVertexColor(unpack(Button.__quality_color))
                end
            end
        end
    end
    
    -- Хук для SkinQuestBorder
    if Masque and Masque.Core and Masque.Core.SkinQuestBorder then
        local origSkinQuestBorder = Masque.Core.SkinQuestBorder
        
        Masque.Core.SkinQuestBorder = function(Region, Button, Skin, xScale, yScale)
            -- Вызываем оригинальную функцию
            origSkinQuestBorder(Region, Button, Skin, xScale, yScale)
            
            -- Проверяем, принадлежит ли кнопка AdiBags
            if Button.__MSQ_Addon == addonName then
                -- Если регион может быть окрашен, модифицируем его для лучшей поддержки цвета
                if CanRegionBeColored(Region) then
                    -- Изменяем режим смешивания для лучшей поддержки цвета
                    local currentBlendMode = Region:GetBlendMode()
                    if currentBlendMode == "BLEND" then
                        Region:SetBlendMode("ADD")
                    end
                end
                
                -- Если у кнопки есть сохраненный цвет качества, применяем его
                if Button.__quality_color and Button.__border_colored then
                    Region:SetVertexColor(unpack(Button.__quality_color))
                end
            end
        end
    end
end

----------------------------------------
-- ЧАСТЬ 4: ИНИЦИАЛИЗАЦИЯ И ЗАПУСК
----------------------------------------

-- Основная функция инициализации
local function InitMasqueFixer()
    Debug("Инициализация системы фиксации окрашивания границ для Masque")
    
    -- Модифицируем основные функции AdiBags
    ModifyUpdateBorderFunction()
    ModifyButtonHandling()
    
    -- Создаем хуки для функций Masque
    HookMasqueSkinButton()
    HookMasqueBorderFunctions()
    
    -- Принудительно обновляем все кнопки
    C_Timer.After(0.5, function()
        addon:SendMessage('AdiBags_UpdateAllButtons')
        Debug("Начальное обновление кнопок выполнено")
    end)
    
    -- Дополнительное обновление после некоторой задержки
    -- (некоторые аддоны могут инициализировать Masque позже)
    C_Timer.After(2, function()
        addon:SendMessage('AdiBags_UpdateAllButtons')
        Debug("Повторное обновление кнопок выполнено")
    end)
end

-- Регистрируем обработчик события входа в игру
addon:RegisterEvent("PLAYER_LOGIN", function()
    -- Отложенный запуск для гарантии, что все аддоны загружены
    C_Timer.After(1, InitMasqueFixer)
end)