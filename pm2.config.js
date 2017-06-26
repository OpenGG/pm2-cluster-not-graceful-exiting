module.exports = {
  apps: [{
    name: 'pm2-demo-graceful',
    script: './server.js',
    cwd: __dirname,
    merge_logs: true,
    env: {
      NODE_ENV: 'production',
    },
    env_dev: {
      NODE_ENV: 'development',
    },
    args: ['9876'],
    instances: 2,
    exec_mode: 'cluster',
  }],
};
