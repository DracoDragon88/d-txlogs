CreateThread(function()
    if GetResourceState('d_lib') == 'started' then
	    exports['d_lib']:CheckLibVersion('2.9.0', GetCurrentResourceName(), 'd-txlogs')
    end
end)