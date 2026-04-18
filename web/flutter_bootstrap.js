_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      useColorEmoji: true,
      renderer: "html"
    });
    await appRunner.runApp();
  }
});
