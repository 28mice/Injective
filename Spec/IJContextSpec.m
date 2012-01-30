
SPEC_BEGIN(IJContextSpec)

describe(@"IJContext", ^{
	__block IJContext *context = nil;
	
	beforeEach(^{
		context = [[IJContext alloc] init];
	});
	
	it(@"should create different instances if set to factory", ^{
		[context registerClass:[ITBrakes class] instantinationMode:IJContextInstantinationModeFactory];
		ITBrakes *obj1 = [context instantinateClass:[ITBrakes class] withProperties:nil];
		ITBrakes *obj2 = [context instantinateClass:[ITBrakes class] withProperties:nil];
		[[obj1 shouldNot] beIdenticalTo:obj2];
	});
	
	it(@"should create same instances if set to singleton", ^{
		[context registerClass:[ITParking class] instantinationMode:IJContextInstantinationModeSingleton];
		ITParking *obj1 = [context instantinateClass:[ITParking class] withProperties:nil];
		ITParking *obj2 = [context instantinateClass:[ITParking class] withProperties:nil];
		[[obj1 should] beIdenticalTo:obj2];
	});
	
	it(@"should provide dependencies for registered classes", ^{
		[context registerClass:[ITCar class] instantinationMode:IJContextInstantinationModeFactory];
		[context registerClass:[ITBrakes class] instantinationMode:IJContextInstantinationModeFactory];
		
		ITCar *car = [context instantinateClass:[ITCar class] withProperties:nil];
		[car.brakes shouldNotBeNil];
	});
	
	pending(@"should provide dependencies for registered classes via ivar", ^{
		[context registerClass:[ITCarIvar class] instantiationMode:IJContextInstantiationModeFactory];
		[context registerClass:[ITBrakes class] instantiationMode:IJContextInstantiationModeFactory];
		
		ITCarIvar *car = [context instantinateClass:[ITCarIvar class] withProperties:nil];
		[[car brakes] shouldNotBeNil];
	});
	
	it(@"should raise if dependencies are not satisfied", ^{
		[context registerClass:[ITCar class] instantinationMode:IJContextInstantinationModeFactory];
		
		[[theBlock(^{
			[context instantinateClass:[ITCar class] withProperties:nil];
		}) should] raiseWithName:NSInternalInconsistencyException];
	});
	
	it(@"should provide values for additional passed params", ^{
		[context registerClass:[ITCar class] instantinationMode:IJContextInstantinationModeFactory];
		[context registerClass:[ITBrakes class] instantinationMode:IJContextInstantinationModeFactory];
		
		ITCar *car = [context instantinateClass:[ITCar class] withProperties:[NSDictionary dictionaryWithObject:@"test" forKey:@"name"]];
		[[car.name should] equal:@"test"];
	});
	
	it(@"should create objects from default context using helper methods", ^{
		[IJContext setDefaultContext:context];
		[context registerClass:[ITCar class] instantinationMode:IJContextInstantinationModeFactory];
		[context registerClass:[ITBrakes class] instantinationMode:IJContextInstantinationModeFactory];
		
		ITCar *car = [ITCar injectiveInstantiate];
		[car.brakes shouldNotBeNil];
		
		car = [ITCar injectiveInstantiateWithProperties:@"test", @"name", nil];
		[[car.name should] equal:@"test"];
	});
	
	afterEach(^{
		[context release];
	});
});

SPEC_END