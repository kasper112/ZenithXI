-- ZenithXI Blood Pact: Rage era adjustments (modules/zenith-public/lua/3-complete/era_bloodpact_rage.lua).
--
-- Hits after the first of a multi-hit Blood Pact use an fTP of 1.0, instead of repeating the first hit's fTP.
-- Chaotic Strike, Shock Strike, Claw and Predator Claws can crit, without TP raising the crit chance (LSB #11921).

describe('Zenith Blood Pact: Rage era adjustments', function()
    local function firstParams(name)
        local params

        stub('xi.job_utils.summoner.onUseBloodPact', function()
        end)

        stub('xi.mobskills.processDamage', false)
        stub('xi.mobskills.mobPhysicalMove', function(_, _, _, _, moveParams)
            params = moveParams

            return { damage = 0 }
        end)

        local pet =
        {
            getWeaponDmg = function()
                return 10
            end,
        }

        xi.actions.abilities.pets[name].onPetAbility({}, pet, {}, {}, {})

        return params
    end

    for _, name in ipairs({ 'axe_kick', 'double_punch', 'chaotic_strike' }) do
        it(string.format('%s uses an fTP of 1.0 after the first hit', name), function()
            local params = firstParams(name)

            for tier = 1, 3 do
                assert(params.fTPSubsequentHits[tier] == 1.0, string.format('fTP is %s', tostring(params.fTPSubsequentHits[tier])))
            end
        end)
    end

    for _, name in ipairs({ 'chaotic_strike', 'shock_strike', 'claw', 'predator_claws' }) do
        it(string.format('%s can crit without TP crit scaling', name), function()
            local params = firstParams(name)

            assert(params.canCrit == true, 'the Blood Pact cannot crit')

            for tier, chance in ipairs(params.criticalChance or {}) do
                assert(chance == 0, string.format('TP tier %d adds %s crit chance', tier, tostring(chance)))
            end
        end)
    end

    it('leaves other physical Blood Pacts unable to crit', function()
        assert(not firstParams('axe_kick').canCrit, 'Axe Kick can crit')
    end)
end)
