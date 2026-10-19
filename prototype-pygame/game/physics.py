"""Shared kinematics used by actors and the level route validator."""
from .config import GRAVITY, JUMP_SPEED, RUN_SPEED, WALK_SPEED, TILE

def fall_damage(distance):
    tiles = distance / TILE
    return 99 if tiles >= 7 else 1 if tiles >= 4 else 0

def jump_reach(speed=RUN_SPEED, rise=0):
    discriminant = JUMP_SPEED ** 2 - 2 * GRAVITY * rise
    if discriminant < 0:
        return 0
    return speed * (JUMP_SPEED + discriminant ** .5) / GRAVITY

def approach(value, target, amount):
    return min(value + amount, target) if value < target else max(value - amount, target)
