-- Решение для Сценария 2: Проблема глубже, чем просто текстура скина

local addonName, addon = ...
local Masque = LibStub('Masque', true)

-- Анализ логики Masque и предлагаемые решения для более глубоких проблем

-- 1. Глубокий анализ перезаписи цветов в Masque
-- В Masque существуют функции, которые могут перезаписывать цвета, установленные AdiBags
local function AnalyzeMasqueColorOverrides()
    -- Исследуем Core.SetTextureColor и Core.SkinIconBorder
    local origSetTextureColor
    
    -- Находим и перехватываем функцию SetTextureColor
    for _, path in ipairs({'Core.SetTextureColor', 'Core.Regions.SetTextureColor'}) do
        local func = path:gsub('%.', '_')
        if _G[func] or Masque[func] or (Masque.Core and Masque.Core[func]) then
            origSetTextureColor = _G[func] or Masque[func] or Masque.Core[func]
            break
        end
    end
    
    if origSetTextureColor then
        -- Создаем хук для SetTextureColor
        local function NewSetTextureColor(Layer, Region, Button, Skin, Color)
            -- Проверяем, это слой границы?
            if Layer == "Border" or Layer == "IconBorder" or Layer == "QuestBorder" then
                -- Сохраняем оригинальные настройки региона
                local r, g, b, a = Region:GetVertexColor()
                
                -- Вызываем оригинальную функцию
                origSetTextureColor(Layer, Region, Button, Skin, Color)
                
                -- Если кнопка принадлежит AdiBags и имеет цвет качества
                if Button.__MSQ_Addon == addonName and Button.__quality_color then
                    -- Восстанавливаем наш цвет качества
                    Region:SetVertexColor(unpack(Button.__quality_color))
                end
            else
                -- Для других слоев просто вызываем оригинальную функцию
                origSetTextureColor(Layer, Region, Button, Skin, Color)
            end
        end
        
        -- Заменяем функцию
        _G[func] = NewSetTextureColor
    end
end

-- 2. Модификация логики AdiBags для синхронизации с циклом обновления Masque
local function ModifyAdiBagsUpdateCycle()
    -- Перехватываем функцию обновления кнопки AdiBags
    local origButtonUpdate = buttonProto.Update
    
    function buttonProto:Update()
        -- Вызываем оригинальную функцию
        origButtonUpdate(self)
        
        -- После обновления кнопки AdiBags, проверяем наличие цвета качества
        if self.hasItem and addon.db.profile.qualityHighlight then
            local _, _, quality = GetItemInfo(self.itemId)
            
            if quality and quality >= ITEM_QUALITY_UNCOMMON then
                local r, g, b = GetItemQualityColor(quality)
                local a = addon.db.profile.qualityOpacity
                
                -- Сохраняем цвет качества в кнопке
                self.__quality_color = {r, g, b, a}
                
                -- Находим все регионы, связанные с границей
                local regions = {
                    self.IconQuestTexture,  -- Стандартная граница AdiBags
                }
                
                -- Добавляем регионы Masque, если они есть
                if self.masqueData then
                    if self.masqueData.Border then table.insert(regions, self.masqueData.Border) end
                    if self.masqueData.IconBorder then table.insert(regions, self.masqueData.IconBorder) end
                    if self.masqueData.QuestBorder then table.insert(regions, self.masqueData.QuestBorder) end
                end
                
                -- Применяем цвет ко всем найденным регионам
                for _, region in ipairs(regions) do
                    if region and region.SetVertexColor then
                        region:SetVertexColor(r, g, b, a)
                    end
                end
            else
                -- Очищаем сохраненный цвет, если качество не подходит
                self.__quality_color = nil
            end
        else
            -- Очищаем сохраненный цвет, если условия не выполняются
            self.__quality_color = nil
        end
    end
end

-- 3. Перехват вызовов Masque для кнопок AdiBags
local function HookMasqueButtonSkinning()
    if Masque and Masque.Group and Masque.Group.AddButton then
        -- Оригинальная функция AddButton
        local origAddButton = Masque.Group.AddButton
        
        -- Создаем хук для AddButton
        Masque.Group.AddButton = function(self, Button, ButtonData, ...)
            -- Вызываем оригинальную функцию
            local result = origAddButton(self, Button, ButtonData, ...)
            
            -- Проверяем, это кнопка AdiBags?
            if Button.__MSQ_Addon == addonName then
                -- Отмечаем, что кнопка была обработана Masque
                Button.__masque_processed = true
                
                -- Если у кнопки есть сохраненный цвет качества, применяем его заново
                if Button.__quality_color then
                    -- Находим все регионы, связанные с границей
                    local regions = {}
                    
                    if ButtonData then
                        if ButtonData.Border then table.insert(regions, ButtonData.Border) end
                        if ButtonData.IconBorder then table.insert(regions, ButtonData.IconBorder) end
                        if ButtonData.QuestBorder then table.insert(regions, ButtonData.QuestBorder) end
                    end
                    
                    -- Применяем цвет ко всем найденным регионам
                    for _, region in ipairs(regions) do
                        if region and region.SetVertexColor then
                            region:SetVertexColor(unpack(Button.__quality_color))
                        end
                    end
                end
            end
            
            return result
        end
    end
end

-- 4. Создание специальной функции для принудительного обновления после изменений Masque
local function CreateMasqueSyncFunction()
    -- Создаем функцию для синхронизации цветов после действий Masque
    addon.SyncWithMasque = function()
        -- Проходим по всем контейнерам AdiBags
        for _, container in pairs(addon.containers or {}) do
            -- Проходим по всем кнопкам в контейнере
            for _, button in pairs(container.buttons or {}) do
                -- Если у кнопки есть сохраненный цвет качества, применяем его заново
                if button.__quality_color then
                    -- Находим все регионы, связанные с границей
                    local regions = {
                        button.IconQuestTexture,  -- Стандартная граница AdiBags
                    }
                    
                    -- Добавляем регионы Masque, если они есть
                    if button.masqueData then
                        if button.masqueData.Border then table.insert(regions, button.masqueData.Border) end
                        if button.masqueData.IconBorder then table.insert(regions, button.masqueData.IconBorder) end
                        if button.masqueData.QuestBorder then table.insert(regions, button.masqueData.QuestBorder) end
                    end
                    
                    -- Применяем цвет ко всем найденным регионам
                    for _, region in ipairs(regions) do
                        if region and region.SetVertexColor then
                            region:SetVertexColor(unpack(button.__quality_color))
                        end
                    end
                end
            end
        end
    end
    
    -- Регистрируем обработчик для событий Masque
    if Masque and Masque.Register then
        Masque.Register(addonName, function()
            -- Вызываем нашу функцию синхронизации с небольшой задержкой
            C_Timer.After(0.1, addon.SyncWithMasque)
        end)
    end
    
    -- Регистрируем обработчик для событий AdiBags
    addon:RegisterMessage("AdiBags_UpdateBorder", function(event, button)
        -- Если кнопка была обработана Masque, проверяем необходимость синхронизации
        if button.__masque_processed and button.__quality_color then
            -- Находим все регионы, связанные с границей
            local regions = {}
            
            if button.masqueData then
                if button.masqueData.Border then table.insert(regions, button.masqueData.Border) end
                if button.masqueData.IconBorder then table.insert(regions, button.masqueData.IconBorder) end
                if button.masqueData.QuestBorder then table.insert(regions, button.masqueData.QuestBorder) end
            end
            
            -- Применяем цвет ко всем найденным регионам
            for _, region in ipairs(regions) do
                if region and region.SetVertexColor then
                    region:SetVertexColor(unpack(button.__quality_color))
                end
            end
        end
    end)
end

-- Основная функция инициализации решения
local function InitSolution()
    -- Отложим инициализацию до полной загрузки UI
    C_Timer.After(0.5, function()
        AnalyzeMasqueColorOverrides()
        ModifyAdiBagsUpdateCycle()
        HookMasqueButtonSkinning()
        CreateMasqueSyncFunction()
        
        -- Принудительно обновляем все кнопки после применения наших изменений
        addon:SendMessage('AdiBags_UpdateAllButtons')
    end)
end

-- Запускаем решение после инициализации аддона
addon:RegisterEvent("PLAYER_LOGIN", InitSolution)