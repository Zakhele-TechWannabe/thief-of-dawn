"""Resolve strikes only during their active window, with directional parries."""
def strike(attacker, defender, blocking=False, block_age=0):
    if defender.hp<=0 or abs(attacker.x-defender.x)>39 or abs(attacker.y-defender.y)>18:
        return 'miss'
    facing = getattr(defender,'facing',1)
    in_front=(attacker.x-defender.x)*facing>0
    if blocking and in_front:
        if block_age<=.22:
            attacker.stun=.65
            attacker.attack_time=0
            return 'parry'
        return 'block'
    defender.hurt(1, attacker.facing*95)
    return 'hit'
