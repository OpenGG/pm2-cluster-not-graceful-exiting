module.exports = {
  apps: [{
    name: 'pm2-demo-graceful-dirty-fix',
    script: './server.js',
    cwd: __dirname,
    merge_logs: true,
    env: {
      NODE_ENV: 'production',
    },
    env_dev: {
      NODE_ENV: 'development',
    },
    args: ['9875', '--dirty-fix'],
    instances: 2,
    exec_mode: 'cluster',
  }],
};
