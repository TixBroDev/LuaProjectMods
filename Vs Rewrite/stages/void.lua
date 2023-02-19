
function onCreate()
   makeLuaSprite('encoresky','raymarcher1',0,0)
   setScrollFactor('encoresky', 1.0, 1.0)
   scaleObject('encoresky',1.1,1.1)



   setSpriteShader('encoresky',"blaze")

   addLuaSprite('encoresky',false);
   
end

function onUpdate()

   setShaderFloat("encoresky", "iTime", os.clock())
end