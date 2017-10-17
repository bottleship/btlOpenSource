 macroscript BtlOpenSourceVrayMeshExport category:"BtlOpenSource"
(

	try destroyDialog rtMain
	catch()

	fn convertToVRMesh newPath =
		(
			--Collect the objects for saving		
			local objs = for i in selection where superclassof i == GeometryClass collect i
			if objs.count>0 then
			(			
				print ("BottleshipTools: VRMesh conversion: path set to "+newPath)		
				
				for i = 1 to objs.count do
				(
					print ("BottleshipTools: VRMesh conversion: Converting "+objs[i].name)
					
					--the vrayMeshExport function works on selection, so we need to select the object
					select objs[i]
					
					--Build the file name
					VRMeshFileName = pathConfig.appendPath newPath (objs[i].name)
					
					--store data for transfer to the proxy
					propertyHolder = box()
					propertyHolder.parent = objs[i].parent
					propertyHolder.wireColor = objs[i].wireColor
					propertyHolder.pivot = objs[i].pivot
					
					for i in objs[i].modifiers where classof i == VRayDisplacementMod do addmodifier modHolder i
					local tempName = objs[i].name
					
					--export
					vrayMeshExport meshFile:VRMeshFileName autoCreateProxies:true exportMultiple:false
					
					--find the proxy				
					local proxy = ((for i in objects where matchpattern i.name pattern:("vrayproxy_"+tempName) collect i)[1])
					
					--reapply VrayDisplacement modifiers on the proxy
					for j in propertyHolder.modifiers do addmodifier proxy j
										
					--reapply saved properties and delete the propertyHolder object afterwards
					proxy.pivot = propertyHolder.pivot
					proxy.parent = propertyHolder.parent
					proxy.wirecolor = propertyHolder.wirecolor
					
					delete propertyHolder
				)
				print "BottleshipTools: VRMesh conversion: done"
				
			)
			else print "BottleshipTools: VRMesh conversion: no geometry found in the selection"
		)


	rollout rtMain "BottleshipTools: Convert geometry to VRMesh and proxy loaders" width:450
	(
		editText edtPath "Path"
		button btnStart "Start conversion"	
		
		on btnStart pressed do
		(
			if makedir edtPath.text then
			(
				makeDir edtPath.text
				convertToVRMesh edtPath.text
			)
			else print ("BottleshipTools: VRMesh conversion: error accessing path, aborting")
		)
	
	)
	createDialog rtMain
	
)