import pygame

def draw_hud(surface,world,font):
    pygame.draw.rect(surface,(10,12,20),(0,256,480,14))
    p=world.player
    for i in range(p.max_hp):
        color=(211,66,68) if i<p.hp else (65,44,53)
        x=6+i*8
        pygame.draw.polygon(surface,color,[(x,259),(x+6,259),(x+3,267)])
    text=font.render(world.level.name,False,(194,188,168))
    surface.blit(text,(115,258))
    seconds=max(0,int(world.time_left));label=f'{seconds//60:02d}:{seconds%60:02d}'
    surface.blit(font.render(label,False,(236,183,100) if seconds>300 else (255,80,75)),(442,258))
