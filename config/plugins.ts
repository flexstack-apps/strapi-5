export default ({ env }) => ({
	upload: {
		config: {
			provider: "local",
			providerOptions: {
				sizeLimit: 1000000,
			},
		},
	},
});
