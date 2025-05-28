-- Решение для Сценария 1: Проблема в текстуре скина "Caith"

local addonName, addon = ...
local Masque = LibStub('Masque', true)

-- Анализ логики Masque и предлагаемые решения

-- 1. Использование кастомных свойств при регистрации группы в Masque
-- Masque позволяет зарегистрировать группу кнопок с определенными параметрами
local function ModifyMasqueRegistration()
    -- Получаем существующую группу Masque для AdiBags
    local oldMasqueGroup = buttonProto.masqueGroup
    
    -- Переопределяем группу с новыми параметрами
    buttonProto.masqueGroup = Masque:Group(addonName, addon.L["Backpack button"], {
        -- Добавляем кастомные параметры, которые могут повлиять на обработку границы
        BorderBlendMode = "ADD", -- Пробуем изменить режим смешивания
        -- Это заставит Masque использовать аддитивный режим для границы
        -- что позволит нашему SetVertexColor влиять на цвет даже непрозрачных текстур
    })
    
    -- Перерегистрируем все существующие кнопки с новыми параметрами
    for button in pairs(oldMasqueGroup.Buttons or {}) do
        oldMasqueGroup:RemoveButton(button)
        buttonProto.masqueGroup:AddButton(button, button.masqueData)
    end
end

-- 2. Создание хука для метода SkinIconBorder Masque
-- Это позволит нам изменить способ, которым Masque обрабатывает границы
local function HookMasqueBorderHandling()
    local origSkinIconBorder = Masque.SkinIconBorder or Core.SkinIconBorder
    
    if origSkinIconBorder then
        -- Перехватываем функцию SkinIconBorder
        local function NewSkinIconBorder(Region, Button, Skin, xScale, yScale)
            -- Вызываем оригинальную функцию
            origSkinIconBorder(Region, Button, Skin, xScale, yScale)
            
            -- После того как Masque применил свою обработку, изменяем настройки
            -- для лучшей поддержки перекрашивания
            if Region and Button.__MSQ_Enabled then
                -- Изменяем режим смешивания для лучшего применения цвета
                Region:SetBlendMode("ADD")
                
                -- Сохраняем оригинальную функцию SetVertexColor
                if not Region.__AdiBags_original_SetVertexColor then
                    Region.__AdiBags_original_SetVertexColor = Region.SetVertexColor
                    
                    -- Создаем хук для SetVertexColor
                    Region.SetVertexColor = function(self, r, g, b, a)
                        -- Усиливаем насыщенность цвета для лучшей видимости на золотой границе
                        return self.__AdiBags_original_SetVertexColor(self, r*1.5, g*1.5, b*1.5, a or 1)
                    end
                end
            end
        end
        
        -- Заменяем функцию в Core
        Core.SkinIconBorder = NewSkinIconBorder
    end
end

-- 3. Замена функции UpdateBorder в AdiBags для улучшения совместимости с Masque
local function ModifyUpdateBorder()
    local origUpdateBorder = buttonProto.UpdateBorder
    
    function buttonProto:UpdateBorder(isolatedEvent)
        if self.hasItem and addon.db.profile.qualityHighlight then
            local _, _, quality = GetItemInfo(self.itemId)
            
            if quality and quality >= ITEM_QUALITY_UNCOMMON then
                local r, g, b = GetItemQualityColor(quality)
                local a = addon.db.profile.qualityOpacity
                
                -- Вместо стандартного подхода AdiBags, используем прямое применение цвета
                -- к границе, созданной Masque
                if self.masqueData and self.masqueData.Border then
                    local border = self.masqueData.Border
                    
                    -- Усиливаем цвет для лучшей видимости
                    border:SetVertexColor(r*1.5, g*1.5, b*1.5, a*1.5)
                    border:Show()
                    
                    -- Помечаем, что граница уже окрашена
                    self.__border_colored = true
                    
                    -- Скрываем стандартную границу AdiBags
                    self.IconQuestTexture:Hide()
                    
                    if isolatedEvent then
                        addon:SendMessage('AdiBags_UpdateBorder', self)
                    end
                    return
                end
            end
        end
        
        -- Если мы здесь, значит, особые случаи не сработали
        -- Восстанавливаем оригинальную границу, если она была окрашена ранее
        if self.__border_colored and self.masqueData and self.masqueData.Border then
            self.masqueData.Border:SetVertexColor(1, 1, 1, 1)
            self.__border_colored = nil
        end
        
        -- Вызываем оригинальную функцию
        return origUpdateBorder(self, isolatedEvent)
    end
end

-- 4. Регистрация кастомного обработчика для колбеков Masque
local function RegisterMasqueCallbacks()
    if Masque and Masque.Register then
        -- Регистрируем обработчик для событий Masque
        Masque.Register(addonName, function(addon, group, skinID, gloss, backdrop, colors, disabled)
            -- Это будет вызвано, когда пользователь изменит скин или настройки Masque
            -- Мы можем использовать это событие для повторного применения наших модификаций
            C_Timer.After(0.1, function()
                -- Принудительно обновляем все кнопки
                addon:SendMessage('AdiBags_UpdateAllButtons')
            end)
        end)
    end
end

-- Основная функция инициализации решения
local function InitSolution()
    -- Отложим инициализацию до полной загрузки UI
    C_Timer.After(0.5, function()
        ModifyMasqueRegistration()
        HookMasqueBorderHandling()
        ModifyUpdateBorder()
        RegisterMasqueCallbacks()
        
        -- Принудительно обновляем все кнопки после применения наших изменений
        addon:SendMessage('AdiBags_UpdateAllButtons')
    end)
end

-- Запускаем решение после инициализации аддона
addon:RegisterEvent("PLAYER_LOGIN", InitSolution)