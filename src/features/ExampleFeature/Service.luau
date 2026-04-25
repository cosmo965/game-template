local ExampleFeatureService = {}

function ExampleFeatureService.init(self: ExampleFeatureService)
	print("hi from ExampleFeatureService!")
end

export type ExampleFeatureService = typeof(ExampleFeatureService) & {}

return ExampleFeatureService
